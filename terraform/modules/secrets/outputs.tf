output "db_username_secret_arn" {
  description = "ARN of the db_username secret"
  value       = aws_secretsmanager_secret.db_username.arn
}

output "db_password_secret_arn" {
  description = "ARN of the db_password secret"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "api_key_secret_arn" {
  description = "ARN of the api_key secret"
  value       = aws_secretsmanager_secret.api_key.arn
}

output "db_username_secret_name" {
  description = "Name of the db_username secret"
  value       = aws_secretsmanager_secret.db_username.name
}

output "db_password_secret_name" {
  description = "Name of the db_password secret"
  value       = aws_secretsmanager_secret.db_password.name
}

output "api_key_secret_name" {
  description = "Name of the api_key secret"
  value       = aws_secretsmanager_secret.api_key.name
}
