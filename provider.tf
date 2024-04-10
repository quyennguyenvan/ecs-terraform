provider "aws" {
  version = "~> 3.0"
  region  = "us-west-2"
  profile = "quyennvakaworkmfa"
  # assume_role {
  #   role_arn = var.assumed_role
  # }
}

terraform {
  required_version = ">= 0.13.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
  }
}

provider "http" {}
