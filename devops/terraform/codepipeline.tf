resource "aws_codepipeline" "app_pipeline" {
  name     = "${var.app_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_service_role.arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket.codepipeline_bucket.bucket
  }

  pipeline_type = "V2"

  trigger {
    provider_type = "CodeStarSourceConnection"
    git_configuration {
      source_action_name = "Source"
      push {
        branches {
          includes = [var.github_branch]
        }
      }
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        ConnectionArn   = var.github_connection_arn
        FullRepositoryId = var.github_repo
        BranchName      = var.github_branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.app_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ClusterName = aws_ecs_cluster.app_cluster.name
        ServiceName = aws_ecs_service.app_service.name
        FileName    = "backend/imagedefinitions.json"
      }
    }
  }
}


resource "aws_iam_role" "codepipeline_service_role" {
  name = "${var.app_name}_codepipeline_service_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess",
    "arn:aws:iam::aws:policy/service-role/AWSCodeStarServiceRole",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
  ]
}

resource "aws_iam_policy" "codepipeline_github_policy" {
  name        = "${var.app_name}_codepipeline_github_policy"
  description = "Policy for CodePipeline to use GitHub connection"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "codestar-connections:UseConnection"
        ]
        Resource = var.github_connection_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_github_policy_attachment" {
  role       = aws_iam_role.codepipeline_service_role.name
  policy_arn = aws_iam_policy.codepipeline_github_policy.arn
}

resource "aws_iam_role_policy_attachment" "codepipeline_ecs_policy_attachment" {
  role       = aws_iam_role.codepipeline_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.app_name}-codepipeline-artifacts"

  lifecycle {
    prevent_destroy = false
  }

  depends_on = [null_resource.empty_bucket]
}
