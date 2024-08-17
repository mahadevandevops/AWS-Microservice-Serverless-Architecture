resource "aws_codecommit_repository" "my_repository" {
  repository_name = "my-repository"
  description     = "My CodeCommit repository"
}
