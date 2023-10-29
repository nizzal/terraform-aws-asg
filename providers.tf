terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.13.1"
    }
    random = {
      source = "hashicorp/random"
      version = "3.5.1"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = var.resource_tags
  }
}

provider "random" {
  
}