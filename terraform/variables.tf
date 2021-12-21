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

variable "APP_AWS_ACCESS_KEY_ID" {
  description = "AWS Access Key to be used to list, attach, and detach instances to/from ALB"
  type        = string
}

variable "APP_AWS_SECRET_ACCESS_KEY" {
  description = "AWS Secret Key to be used to list, attach, and detach instances to/from ALB"
  type        = string
}

variable "app_version" {
  description = "ELB_API app version to be used for tagging container image"
  type        = string
}
