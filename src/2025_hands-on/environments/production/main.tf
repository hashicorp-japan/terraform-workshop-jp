terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.21.0"
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
}

module "integration" {
  source = "./../../modules/integration"
}