output "secrets_role_arn" {
  description = "ARN of the IRSA role for secrets access"
  value       = aws_iam_role.secrets_role.arn
}

output "alb_controller_role_arn" {
  description = "ARN of the IAM role for AWS Load Balancer Controller"
  value       = aws_iam_role.alb_controller.arn
}