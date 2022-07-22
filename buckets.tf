resource "aws_s3_bucket" "codebuild_bucket" {
  bucket = "${var.project_name}-${random_string.random.id}-codebuild-bucket"
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "${var.project_name}-${random_string.random.id}-codepipeline-bucket"
}
