provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}

# Data source to get the current AWS account ID
data "aws_caller_identity" "current" {}
