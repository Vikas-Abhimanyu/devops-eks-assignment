variable "cluster_name" {
  type        = string
  description = "EKS cluster name"
}

variable "cluster_endpoint" {
  type        = string
  description = "EKS cluster endpoint"
}

variable "cluster_ca" {
  type        = string
  description = "Cluster certificate authority data"
}

variable "cluster_token" {
  type        = string
  description = "Authentication token for Kubernetes provider"
}

variable "irsa_role_arn" {
  type        = string
  description = "IAM Role ARN used by the secrets-reader service account"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID where EKS cluster exists"
}

variable "alb_role_arn" {
  description = "IAM role used by AWS Load Balancer Controller"
  type        = string
}

variable "jenkins_role_arn" {
  description = "ARN of the Jenkins EC2 IAM role"
  type        = string
}

variable "db_username_secret_arn" {
  description = "ARN of the db_username secret"
  type        = string
}

variable "db_password_secret_arn" {
  description = "ARN of the db_password secret"
  type        = string
}

variable "api_key_secret_arn" {
  description = "ARN of the api_key secret"
  type        = string
}