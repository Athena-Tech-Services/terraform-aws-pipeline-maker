
resource "aws_codebuild_project" "codebuild_project" {
  for_each    = var.applications_details
  name        = "${each.value.application_name}_Build"
  description = "${each.value.application_name}'s build project"
  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }
  vpc_config {
    vpc_id             = local.vpc.id
    subnets            = toset(data.aws_subnets.subnets.ids)
    security_group_ids = [data.aws_security_group.public-default-sg.id]
  }
  build_timeout  = 30
  queued_timeout = 30
  service_role   = aws_iam_role.landing_page_build_role.arn
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:${var.terraform_version}"
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
    buildspec           = data.template_file.buildspec.rendered
    git_clone_depth     = 0
    insecure_ssl        = false
    report_build_status = false
    type                = "CODEPIPELINE"
  }

}
