
# Create security group to allow traffic from load balancer
module "security_group_allow_http_from_alb" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "allow-from-load-balancer"
  description = "Security group to allow traffic from ALB load balancer"

  vpc_id = data.aws_vpc.default.id

  computed_ingress_with_source_security_group_id = [
    {
      description              = "Allow HTTP access on port 80"
      rule                     = "http-80-tcp"
      source_security_group_id = module.security_group_allow_http.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
}

# Create security group for allowing http traffic
module "security_group_allow_http" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "allow-http"
  description = "Security group to allow HTTP access"

  vpc_id = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["http-80-tcp"]
  egress_rules        = ["all-all"]
}

# Create security group to allow ssh
module "security_group_allow_ssh" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "allow-ssh"
  description = "Security group to allow SSH access"

  vpc_id = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
  egress_rules        = ["all-all"]
}