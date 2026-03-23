variable "cluster_name" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "oidc_thumbprint" {
  description = "OIDC provider thumbprint"
  type        = string
  default     = "9e99a48a9960b14926bb7f3b02e22da0afd0e0c9"
}

variable "ssh_key_name" {
  description = "EC2 SSH key name for node group remote access"
  type        = string
}

variable "node_sg_id" {
  description = "Security group ID allowed to SSH into nodes"
  type        = string
}
