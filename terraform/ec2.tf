# Get ami id
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

# Get default VPC data
data "aws_vpc" "default" {
  default = true
}

# Create a Key Pair
resource "aws_key_pair" "terraform_key_pair" {
  key_name   = "terraform-key"
  public_key = var.ssh_public_key
}

# Create instance
resource "aws_instance" "elb_api" {
  ami           = data.aws_ami.ubuntu.id
  key_name      = aws_key_pair.terraform_key_pair.key_name
  instance_type = "t2.micro"

  vpc_security_group_ids = [
    module.security_group_allow_http_from_alb.security_group_id,
    module.security_group_allow_ssh.security_group_id
  ]

  tags = {
    Name        = "elb-api"
    environment = var.environment
  }
}

# Locally build a docker image and push it to AWS ECR
resource "null_resource" "build" {
  provisioner "local-exec" {
    working_dir = "../ansible"
    interpreter = ["/bin/sh", "-c"]

    command = <<-EOT
      ansible-playbook build-elb-api.yaml \
      -e 'ansible_connection=local ansible_python_interpreter="/usr/bin/env python3"' \
      --extra-vars "aws_region=${var.aws_region} ecr_repository_url=${aws_ecr_repository.elb_api.repository_url} app_version=${var.app_version}" \
      -i localhost,

    EOT

    environment = {
      AWS_ACCESS_KEY_ID         = "${var.AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY     = "${var.AWS_SECRET_ACCESS_KEY}"
      APP_AWS_ACCESS_KEY_ID     = "${var.APP_AWS_ACCESS_KEY_ID}"
      APP_AWS_SECRET_ACCESS_KEY = "${var.APP_AWS_SECRET_ACCESS_KEY}"
    }
  }

  depends_on = [aws_ecr_repository.elb_api]
}

# Deploy docker image to AWS ECR
resource "null_resource" "deploy" {
  provisioner "local-exec" {
    working_dir = "../ansible"
    interpreter = ["/bin/sh", "-c"]

    command = <<-EOT
      ansible-playbook deploy-elb-api.yaml \
      -e "ansible_user=ubuntu" \
      --private-key "${var.private_key_filepath}" \
      --extra-vars "aws_region=${var.aws_region} ecr_repository_url=${aws_ecr_repository.elb_api.repository_url} app_version=${var.app_version}" \
      -i ${aws_instance.elb_api.public_ip},
    EOT

    environment = {
      AWS_ACCESS_KEY_ID         = "${var.AWS_ACCESS_KEY_ID}"
      AWS_SECRET_ACCESS_KEY     = "${var.AWS_SECRET_ACCESS_KEY}"
      APP_AWS_ACCESS_KEY_ID     = "${var.APP_AWS_ACCESS_KEY_ID}"
      APP_AWS_SECRET_ACCESS_KEY = "${var.APP_AWS_SECRET_ACCESS_KEY}"
    }
  }

  depends_on = [null_resource.build]
}