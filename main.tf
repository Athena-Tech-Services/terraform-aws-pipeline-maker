provider "aws" {
  region = var.region
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}

data "aws_kms_alias" "s3kmskey" {
  name = "alias/aws/s3"
}

