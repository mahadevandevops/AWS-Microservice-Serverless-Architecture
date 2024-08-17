resource "aws_iam_role" "codepipeline_role1" {
  name = "codepipeline_role1"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = ["codepipeline.amazonaws.com",
            "codedeploy.amazonaws.com",
          "codebuild.amazonaws.com"]
        }
      },
    ]
  })
}

# resource "aws_iam_policy" "codepipeline_policy1" {
#   name = "codepipeline-policy1"

#   policy = jsonencode({
#     Version = "2012-10-17",
#     Statement = [
#       {
#         Effect = "Allow",
#         Action = [
#           "codecommit:GitPull"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "codebuild:BatchGetBuilds",
#           "codebuild:StartBuild",
#           "codebuild:BatchGetBuildBatches",
#           "codebuild:BatchStartBuilds",
#           "codebuild:BatchGetProjects"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "ecs:DescribeServices",
#           "ecs:UpdateService",
#           "ecs:DescribeTaskDefinition",
#           "ecs:DescribeTasks",
#           "ecs:ListTasks",
#           "ecs:RegisterTaskDefinition"
#         ],
#         Resource = "*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "s3:GetObject",
#           "s3:PutObject"
#         ],
#         Resource = "arn:aws:s3:::${aws_s3_bucket.artifact_bucket.bucket}/*"
#       },
#       {
#         Effect = "Allow",
#         Action = [
#           "iam:PassRole"
#         ],
#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "codepipeline_policy_attach" {
#   role       = aws_iam_role.codepipeline_role1.name
#   policy_arn = aws_iam_policy.codepipeline_policy1.arn
# }

resource "aws_iam_policy" "codepipeline_policy1" {
  name = "codepipeline-policy1"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codecommit:GetBranch",
          "codecommit:GetRepository",
          "codecommit:ListBranches",
          "codecommit:ListRepositories",
          "codecommit:GitPull",
          "codecommit:GetCommit",
          "codecommit:UploadArchive",
          "codecommit:GetUploadArchiveStatus"
        ],
        Resource = aws_codecommit_repository.my_repository.arn
      },
      {
        Effect = "Allow",
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild",
          "codebuild:BatchGetBuildBatches",
          "codebuild:BatchStartBuilds",
          "codebuild:BatchGetProjects"

        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Resource = [
          "*",
        ],
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ecs:DescribeServices",
          "ecs:UpdateService",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTasks",
          "ecs:ListTasks",
          "ecs:RegisterTaskDefinition"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:CompleteLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:InitiateLayerUpload",
          "ecr:BatchCheckLayerAvailability",
          "ecr:PutImage"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:GetBucketAcl",
          "s3:GetBucketLocation"
        ],
        Resource = "arn:aws:s3:::${aws_s3_bucket.artifact_bucket.bucket}/*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codepipeline_policy_attach" {
  role       = aws_iam_role.codepipeline_role1.name
  policy_arn = aws_iam_policy.codepipeline_policy1.arn
}


#### Code Pipeline
resource "aws_codepipeline" "my_pipeline" {
  name     = "my-pipeline"
  role_arn = aws_iam_role.codepipeline_role1.arn

  artifact_store {
    location = aws_s3_bucket.artifact_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      version          = "1"
      name             = "SourceAction"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName = aws_codecommit_repository.my_repository.repository_name
        BranchName     = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      version          = "1"
      name             = "BuildAction"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.my_build_project.name
      }
    }
  }
   stage {
    name = "Approval"

    action {
      version  = "1"
      name     = "ManualApproval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"

      configuration = {
        CustomData = "Please approve the deployment to ECS."
      }
    }
  }
  stage {
    name = "Deploy"

    action {
      version         = "1"
      name            = "DeployToECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["build_output"]
      configuration = {
      ClusterName      = aws_ecs_cluster.ecs_cluster.name
      ServiceName      = aws_ecs_service.ecs_service.name
      #ImageDefinitions = "imagedefinitions.json"
      }
    }
  }
}
