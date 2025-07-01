# (root)/providers.tf
terraform {
  required_version = ">= 1.12.0" # If HCP remote backend is used
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.98"
    }
  }

  cloud {
    organization = "my-cloud-org"
    workspaces {
      name = "wordpress-terraform-iam-policies"
    }
  }
}

provider "aws" {
  region = var.aws_region # Set in Terraform Cloud as TF_VAR_aws_region
}