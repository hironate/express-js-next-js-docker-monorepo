resource "aws_codebuild_project" "app_build" {
  name          = "${var.app_name}-build"
  service_role  = aws_iam_role.codebuild_service_role.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    privileged_mode             = true
    environment_variable {
      name  = "AWS_DEFAULT_REGION"
      value = var.region
    }
    environment_variable {
      name  = "ECR_REPOSITORY"
      value = aws_ecr_repository.app.repository_url
    }
  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = file("buildspec.yml")
  }

  cache {
    type = "NO_CACHE"
  }

  logs_config {
    cloudwatch_logs {
      group_name = "/aws/codebuild/${var.app_name}-build"
      stream_name = "build-log"
    }
  }
}

resource "aws_iam_role" "codebuild_service_role" {
  name = "${var.app_name}_codebuild_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "codebuild.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser",
    "arn:aws:iam::aws:policy/AWSCodeBuildDeveloperAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}

resource "aws_iam_policy" "codebuild_cloudwatch_policy" {
  name = "${var.app_name}_codebuild_cloudwatch_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = [
          "arn:aws:logs:*:*:*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild_cloudwatch_policy_attachment" {
  role       = aws_iam_role.codebuild_service_role.name
  policy_arn = aws_iam_policy.codebuild_cloudwatch_policy.arn
}

