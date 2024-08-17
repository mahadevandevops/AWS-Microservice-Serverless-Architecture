resource "aws_codebuild_project" "my_build_project" {
  name         = "my-build-project"
  service_role = aws_iam_role.codepipeline_role1.arn
  artifacts {
    type     = "S3"
    location = aws_s3_bucket.artifact_bucket.bucket
  }
  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image        = "aws/codebuild/standard:5.0"
    type         = "LINUX_CONTAINER"
    environment_variable {
      name  = "AWS_ACCOUNT_ID"
      value = "185212935946"
    }
    environment_variable {
      name  = "IMAGE_REPO_NAME"
      value = aws_ecr_repository.my_repository.name
    }
    environment_variable {
      name  = "IMAGE_TAG"
      value = "latest"
    }
  }
  source {
    type      = "CODECOMMIT"
    location  = aws_codecommit_repository.my_repository.clone_url_http
    buildspec = "buildspec.yml" # Reference to the external buildspec file
  }
}
