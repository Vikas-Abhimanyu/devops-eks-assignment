resource "aws_ecr_repository" "backend" {
  name = "devops-app-backend"
}

resource "aws_ecr_repository" "frontend" {
  name = "devops-app-frontend"
}