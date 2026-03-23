output "backend_repo" {
  value = aws_ecr_repository.backend.repository_url
}

output "frontend_repo" {
  value = aws_ecr_repository.frontend.repository_url
}