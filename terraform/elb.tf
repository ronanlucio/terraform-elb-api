# Get subnets from default vpc
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create LB Target Group
resource "aws_lb_target_group" "elb_api" {
  name     = "tg-elb-api"
  port     = 80
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path     = "/healthcheck"
    port     = 80
    protocol = "HTTP"
    matcher  = 200
  }
}

# Attach instance to Target Group
resource "aws_lb_target_group_attachment" "elb_api" {
  target_group_arn = aws_lb_target_group.elb_api.arn
  target_id        = aws_instance.elb_api.id
  port             = 80
}

# Create ALB
resource "aws_lb" "default_alb" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [module.security_group_allow_http.security_group_id]
  subnets            = data.aws_subnets.default.ids
  #subnets            = [for subnet in data.aws_subnets.public : subnet.id]

  #   access_logs {
  #     bucket  = aws_s3_bucket.lb_logs.bucket
  #     prefix  = "default-lb"
  #     enabled = true
  #   }
}

# Create ALB Listener
resource "aws_lb_listener" "default_alb" {
  load_balancer_arn = aws_lb.default_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.elb_api.arn
  }
}