data "aws_iam_policy_document" "codebuild_iam_policy_document" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.codebuild_iam_policy_document
  path               = "/ci-cd-automated-roles/"
}

data "aws_iam_policy_document" "codebuild_role_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "ecr:*",
      "ssm:*"
    ]
    resources = [
      "*"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild_policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.aws_iam_policy_document.codebuild_role_iam_policy_document
}
