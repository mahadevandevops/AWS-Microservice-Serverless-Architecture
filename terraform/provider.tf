terraform {
  required_version = "~> 1.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
#   backend "s3" {
#     bucket = "tf-store-statedata"
#     key    = "terraform.tfstate"
#     region = "us-east-1"
#   }
 }
provider "aws" {
  region     = "us-east-1"
  access_key = "" # -> Not take this value when add backend
  secret_key = ""
}
