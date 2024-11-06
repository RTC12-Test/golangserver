# Backend Configuration
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.58.0"
    }
  }
  backend "s3" {
  }
}

provider "aws" {
  region = lookup(local.configs, "region")
}
