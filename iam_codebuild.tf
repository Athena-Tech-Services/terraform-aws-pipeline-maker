data "aws_iam_policy_document" "codebuild_iam_policy_document" {
  statement {
    actions = [ "sts:AssumeRole" ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [ "codebuild.amazonaws.com" ]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_iam_policy_document
  path = "/ci-cd-automated-roles/"
}

resource "aws_iam_policy" "codebuild_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject"
    ]
    resources = [
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["codestar-connections:UseConnection"]
    resources = ["${data.aws_codestarconnections_connection.codestar_connection.arn}"]
  }
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = ["*"]
  }
}
