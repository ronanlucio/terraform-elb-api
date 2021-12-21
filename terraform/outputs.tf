output "instance_public_ip" {
  value = aws_instance.elb_api.public_ip
}

output "alb_dns_name" {
  value = aws_lb.default_alb.dns_name
}

output "ecr_repository_url" {
  value = aws_ecr_repository.elb_api.repository_url
}