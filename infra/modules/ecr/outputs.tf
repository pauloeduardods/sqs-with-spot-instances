output "ecr_repo" {
  description = "The ECR repository"
  value       = {
    repository_url = aws_ecr_repository.ecr_repo.repository_url
  }
}