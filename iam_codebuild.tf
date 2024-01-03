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
  name               = "codebuild-role-${var.project_name}"
  assume_role_policy = data.aws_iam_policy_document.codebuild_iam_policy_document.json
  path               = "/ci-cd-automated-roles/"
}

data "aws_iam_policy_document" "codebuild_role_iam_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:*",
      "ecr:*",
      "ssm:*",
      "lambda:*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParameters",
    ]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["*"]
  }
}

data "aws_iam_policy_document" "codebuild_role_iam_policy_document_full_access" {
  statement {
    effect = "Allow"
    actions = [
      "*"
    ]
    resources = [
      "*"
    ]
  }
}

locals {
  codebuild_iam_policy = var.iam_codebuild_full_access ? data.aws_iam_policy_document.codebuild_role_iam_policy_document_full_access.json : data.aws_iam_policy_document.codebuild_role_iam_policy_document.json
}
resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "codebuild_policy"
  role   = aws_iam_role.codebuild_role.id
  policy = local.codebuild_iam_policy
}
