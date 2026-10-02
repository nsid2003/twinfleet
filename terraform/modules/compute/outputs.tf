output "alb_dns_name" {
  description = "Nom DNS de l'ALB"
  value       = aws_lb.app.dns_name
}

output "alb_url" {
  description = "URL HTTP de l'application"
  value       = "http://${aws_lb.app.dns_name}"
}

output "asg_name" {
  description = "Nom de l'Auto Scaling Group"
  value       = aws_autoscaling_group.app.name
}

output "target_group_arn" {
  description = "ARN du Target Group"
  value       = aws_lb_target_group.app.arn
}

output "instance_role_name" {
  description = "Nom du rôle IAM des instances"
  value       = aws_iam_role.ec2.name
}
