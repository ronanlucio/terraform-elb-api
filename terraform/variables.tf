variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "environment" {
  description = "Environment accepts development, stage or production"
  type        = string
  default     = "development"
}

variable "alb_name" {
  description = "Load Balancer (ALB) name"
  type        = string
}

variable "ssh_public_key" {
  description = "SSH Public key to be used for SSH access"
  type        = string
}