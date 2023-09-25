terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.13.1"
    }
  }
  required_version = ">= 1.2.0"

  backend "s3" {
    #    bucket         = "tf-remote-backend-5601"
    #    key            = "state/terraform.tfstate"
    #    region         = "us-east-1"
    #    encrypt        = true
    #    dynamodb_table = "tf-remote-backend"
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = var.resource_tags
  }
}
