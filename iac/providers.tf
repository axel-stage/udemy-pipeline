terraform {
  required_version = ">=1.9"
  backend "local" {
    path = "state/terraform.state"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.23.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }
  }
}

provider "aws" {
  region                   = var.region
  profile                  = "default"
  shared_config_files      = ["/home/xl/.aws/config"]
  shared_credentials_files = ["/home/xl/.aws/credentials"]
  default_tags {
    tags = {
      Provisioned = "Terraform"
      Project     = var.project
      Environment = var.environment
    }
  }
}
