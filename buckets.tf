
resource "aws_s3_bucket" "codepipeline_bucket" {
  count  = var.use_default_artifact_s3_buckets ? 1 : 0
  bucket = "${var.project_name}-${random_string.random.id}-codepipeline-bucket"
}

data "aws_s3_bucket" "codepipeline_bucket" {
  count  = var.use_default_artifact_s3_buckets ? 0 : 1
  bucket = var.codepipeline_bucket
}

locals {
  aws_s3_codepipeline_bucket = var.use_default_artifact_s3_buckets ? aws_s3_bucket.codepipeline_bucket : data.aws_s3_bucket.codepipeline_bucket
}
