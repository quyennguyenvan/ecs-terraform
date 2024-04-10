resource "aws_ecr_repository" "image_repo" {
  name                 = var.ecs_cluster_name
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = true
  }
}
#===================================================
# OUTPUT
#===================================================
output "ecr_repository_arn" {
  value = aws_ecr_repository.image_repo.arn
}
