terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  profile = local.aws_access_profile
  region  = var.aws_region
}

provider "aws" {
  alias   = "backup"
  profile = local.aws_access_profile
  region  = var.aws_backup_region
}
