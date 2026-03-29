variable "vpc_id" {
  description = "VPC ID for security group"
  type        = string
}

variable "public_subnets" {
  type = list(string)
}

variable "jenkins_instance_type" {
  default = "c7i-flex.large"
}

variable "ansible_instance_type" {
  default = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID to use for Jenkins/Ansible servers"
  default     = "ami-05d2d839d4f73aafb" # Example Ubuntu 24.04
}

variable "region" {
  description = "AWS region for dynamic ARN references"
  type        = string
}

variable "cluster_name" {
  description = "EKS cluster name for dynamic ARN references"
  type        = string
}