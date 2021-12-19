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
