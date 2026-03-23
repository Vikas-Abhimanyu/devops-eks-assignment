output "secrets_role_arn" {
  value = aws_iam_role.secrets_role.arn
}

output "alb_controller_role_arn" {
  value = aws_iam_role.alb_controller.arn
}
