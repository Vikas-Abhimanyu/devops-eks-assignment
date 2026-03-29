variable "eks_oidc_provider_arn" {
  type        = string
  description = "ARN of the EKS OIDC provider"
}

variable "eks_oidc_provider_url" {
  type        = string
  description = "URL of the EKS OIDC provider"
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