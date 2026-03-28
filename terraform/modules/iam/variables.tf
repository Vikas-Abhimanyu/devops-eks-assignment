variable "oidc_provider" {
  type        = string
  description = "OIDC provider URL for the EKS cluster"
}

variable "db_username_secret_arn" {
  type        = string
  description = "ARN of the DB username secret"
}

variable "db_password_secret_arn" {
  type        = string
  description = "ARN of the DB password secret"
}

variable "api_key_secret_arn" {
  type        = string
  description = "ARN of the API key secret"
}

variable "jenkins_role_name" {
  type        = string
  description = "Name of the Jenkins EC2 IAM role"
}