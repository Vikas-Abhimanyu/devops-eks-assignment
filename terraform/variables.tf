variable "region" {
  default = "ap-south-1"
}

variable "cluster_name" {
  default = "devops-eks"
}

variable "key_name" {
  description = "EC2 SSH key pair"
  default     = "bastion_key"
}

variable "db_name" {
  description = "Database name for RDS"
  type        = string
  default     = "appdb" # or any name you want
}

variable "db_username" {
  sensitive = true
}

variable "db_password" {
  sensitive = true
}

variable "api_key" {
  sensitive = true
}

variable "ssh_key_name" {
  description = "EC2 key pair name for SSH access"
  type        = string
}
