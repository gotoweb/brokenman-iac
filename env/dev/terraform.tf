terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"

  backend "s3" {
    key = "terraform.tfstate"
    region  = "ap-northeast-2"
    encrypt = true
    dynamodb_table = "terraform-lock"
  }
}

provider "aws" {
  region  = "ap-northeast-2"
}
