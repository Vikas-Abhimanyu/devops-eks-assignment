# Separate secrets for each credential

resource "aws_secretsmanager_secret" "db_username" {
  name                       = "db_username"
  description                = "Database username for RDS instance"
  recovery_window_in_days    = 7
  force_overwrite_replica_secret = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "db_username_value" {
  secret_id     = aws_secretsmanager_secret.db_username.id
  secret_string = var.db_username
}

resource "aws_secretsmanager_secret" "db_password" {
  name                       = "db_password"
  description                = "Database password for RDS instance"
  recovery_window_in_days    = 7
  force_overwrite_replica_secret = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "db_password_value" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

resource "aws_secretsmanager_secret" "api_key" {
  name                       = "api_key"
  description                = "API key for external service"
  recovery_window_in_days    = 7
  force_overwrite_replica_secret = true

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_secretsmanager_secret_version" "api_key_value" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key
}
