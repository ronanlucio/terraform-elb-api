output "instance_public_ip" {
  value = aws_instance.elb_api.public_ip
}

output "alb_dns_name" {
  value = aws_lb.default_alb.dns_name
}