terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.60.0"
    }
  }
}

provider "aws" {
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
  region = "ap-northeast-1"
}

module "storage" {
  source = "./../../modules/storage"
  bucket_name = "my-unique-sample-name-hno3" # Ensure this is globally unique
}

module "integration" {
  source = "./../../modules/integration"
}
