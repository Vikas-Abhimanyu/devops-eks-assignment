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
