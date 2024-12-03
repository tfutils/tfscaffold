terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.79.0"
    }
  }

  required_version = ">= 1.0.0"
}
