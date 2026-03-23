# ECR Repository
resource "aws_ecr_repository" "my_app_repo" {
  name                 = "my-app-repo"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "my-app-repo"
  }
}

resource "aws_ecr_lifecycle_policy" "cleanup" {

  repository = aws_ecr_repository.my_app_repo.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

# Output the repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.my_app_repo.repository_url
}   