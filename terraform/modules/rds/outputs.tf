output "endpoint" {
  value = aws_db_instance.postgres.endpoint
}

output "port" {
  value = aws_db_instance.postgres.port
}

output "db_password" {
  value     = local.db_password
  sensitive = true
}
