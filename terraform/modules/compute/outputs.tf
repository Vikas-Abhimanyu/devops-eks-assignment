output "node_sg_id" {
  description = "Security group ID for Jenkins/EKS worker nodes"
  value       = aws_security_group.devops_sg.id
}

output "jenkins_ip" {
  value = aws_instance.jenkins_host.public_ip
}

output "ansible_ip" {
  value = aws_instance.ansible_host.public_ip
}

output "jenkins_role_name" {
  value       = aws_iam_role.jenkins_role.name
  description = "Name of the Jenkins EC2 IAM role"
}

output "jenkins_role_arn" {
  value       = aws_iam_role.jenkins_role.arn
  description = "ARN of the Jenkins EC2 IAM role"
}
