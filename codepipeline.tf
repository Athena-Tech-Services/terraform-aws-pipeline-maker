
resource "aws_codepipeline" "codepipeline" {
  name     = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  artifact_store {
    location = local.aws_s3_codepipeline_bucket[0].bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.id
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    dynamic "action" {
      for_each = var.applications_details
      content {
        name             = action.value.application_name
        category         = "Source"
        owner            = "AWS"
        provider         = "CodeStarSourceConnection"
        version          = "1"
        output_artifacts = ["source_output_${action.value.application_name}"]

        configuration = {
          ConnectionArn    = data.aws_codestarconnections_connection.codestar_connection.arn
          FullRepositoryId = "${var.organization_repo_name}/${action.value.application_repo_name}"
          BranchName       = action.value.branchName
        }
      }
    }


  }


  stage {

    name = "Build"
    dynamic "action" {
      for_each = var.applications_details
      content {
        name             = action.value.application_name
        category         = "Build"
        owner            = "AWS"
        provider         = "CodeBuild"
        input_artifacts  = ["source_output_${action.value.application_name}"]
        output_artifacts = ["build_output_${action.value.application_name}"]
        version          = "1"

        configuration = {
          ProjectName          = "${action.value.application_name}_Build"
          PrimarySource        = "source_output_${action.value.application_name}"
          EnvironmentVariables = jsonencode(action.value.application_codebuild_env_variables)
        }
      }
    }
  }

  dynamic "stage" {
    for_each = length([for applications_detail in var.applications_details : applications_detail if applications_detail.has_deploy_stage]) > 0 ? ["1"] : []

    content {
      name = "Deploy"
      dynamic "action" {
        for_each = [for applications_detail in var.applications_details : applications_detail if applications_detail.has_deploy_stage]
        content {
          name            = action.value.application_name
          category        = "Deploy"
          owner           = "AWS"
          provider        = "ECS"
          input_artifacts = ["build_output_${action.value.application_name}"]
          version         = "1"
          configuration = {
            ClusterName       = action.value.application_cluster_name
            ServiceName       = action.value.application_service_name
            DeploymentTimeout = action.value.application_deployment_timeout
          }
        }
      }
    }
  }

}
