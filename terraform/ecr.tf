// Manage your ECR Repository
data "aws_ecr_repository" "ecr_repository" {
    name = "${local.project-name}"
}

// Attaching a policy to clean up untagged images after 1 day
resource "aws_ecr_lifecycle_policy" "ecr_lifecycle_policy" {
  repository = data.aws_ecr_repository.ecr_repository.name

  policy = <<EOF
        {
            "rules": [
                {
                    "rulePriority": 1,
                    "description": "Expire images older than 1 days",
                    "selection": {
                        "tagStatus": "untagged",
                        "countType": "sinceImagePushed",
                        "countUnit": "days",
                        "countNumber": 1
                    },
                    "action": {
                        "type": "expire"
                    }
                }
            ]
        }
        EOF
}