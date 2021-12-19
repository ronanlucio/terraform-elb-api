terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Set AWS provider
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      team   = "SRE"
      author = "Ronan Lucio Pereira"
    }
  }
}