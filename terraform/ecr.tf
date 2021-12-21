# Create AWS ECR repository
resource "aws_ecr_repository" "elb_api" {
  name = "elb_api"

  image_scanning_configuration {
    scan_on_push = true
  }
}
