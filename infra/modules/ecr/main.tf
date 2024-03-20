resource "aws_ecr_repository" "ecr_repo" {
  name                 = "${var.project_name}_ecr_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name        = "SpotInstanceQueue_${var.project_name}"
    CreatedBy   = "Terraform"
  }
}

output "ecr_repository_url" {
  value = aws_ecr_repository.ecr_repo.repository_url
}
