
resource "aws_codebuild_project" "codebuild_project" {
  for_each    = var.applications_details
  name        = "${each.value.application_name}_Build"
  description = "${each.value.application_name}'s build project"
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  dynamic "vpc_config" {
    for_each = local.vpc_config
    content {
      vpc_id             = vpc_config.vpc_id
      subnets            = vpc_config.subnets
      security_group_ids = vpc_config.security_group_ids
    }
  }

  build_timeout  = 30
  queued_timeout = 30
  service_role   = aws_iam_role.codebuild_role.arn
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
  }

  artifacts {
    encryption_disabled    = false
    override_artifact_name = false
    packaging              = "NONE"
    type                   = "CODEPIPELINE"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
    }

    s3_logs {
      encryption_disabled = false
      status              = "DISABLED"
    }


  }
  source {
    buildspec           = each.value.buildspec_path
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

}
