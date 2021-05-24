terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.31.0"
    }
  }

  required_version = ">= 0.14.7"
}
