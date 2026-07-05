output "alb_id" {
  description = "ALB ID."
  value       = aws_lb.this.id
}

output "alb_arn" {
  description = "ALB ARN."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "ALB DNS name."
  value       = aws_lb.this.dns_name
}

output "alb_zone_id" {
  description = "ALB hosted zone ID."
  value       = aws_lb.this.zone_id
}

output "target_group_arn" {
  description = "Application target group ARN."
  value       = aws_lb_target_group.this.arn
}

output "target_group_name" {
  description = "Application target group name."
  value       = aws_lb_target_group.this.name
}

output "http_listener_arn" {
  description = "HTTP listener ARN."
  value       = try(aws_lb_listener.http_redirect[0].arn, aws_lb_listener.http_forward[0].arn)
}

output "https_listener_arn" {
  description = "HTTPS listener ARN."
  value       = try(aws_lb_listener.https[0].arn, null)
}
