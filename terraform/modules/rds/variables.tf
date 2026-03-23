variable "db_name" {
  default = "appdb"
}

variable "db_username" {
  default = "postgres_user"
}

variable "db_password_secret_arn" {
  description = "Secrets Manager ARN containing DB password"
  type        = string
}

variable "db_password_key" {
  description = "Key name inside the Secrets Manager JSON for the DB password"
  type        = string
  default     = "db_password"
}

variable "vpc_id" {
  type = string
}

variable "private_subnets" {
  type = list(string)
}

variable "eks_node_group_sg" {
  description = "Security group ID of the EKS worker nodes"
  type        = string
}
