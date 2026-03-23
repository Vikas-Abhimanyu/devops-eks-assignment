variable "log_group_name" {
  description = "CloudWatch log group name for EKS cluster logs"
  type        = string
  default     = "/aws/eks/devops"
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for CloudWatch alarm"
  type        = number
  default     = 80
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "node_group_name" {
  description = "EKS node group name"
  type        = string
}

variable "region" {
  description = "AWS region for CloudWatch logs"
  type        = string
}