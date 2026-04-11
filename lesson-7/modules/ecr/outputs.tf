output "ecr_repository_url" {
  description = "URL ECR репозиторію"
  value       = aws_ecr_repository.main.repository_url
}

output "ecr_repository_name" {
  description = "Назва ECR репозиторію"
  value       = aws_ecr_repository.main.name
}