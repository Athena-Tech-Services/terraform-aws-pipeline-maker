resource "aws_codepipeline" "codepipeline" {
  name = "${var.project_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
   artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    encryption_key {
      id   = data.aws_kms_alias.s3kmskey.id
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    for_each = var.applications_details
    action {
      name             = each.value.application_name
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output_${each.value.application_name}"]

      configuration = {
        ConnectionArn    = data.aws_codestarconnections_connection.codestar_connection.arn
        FullRepositoryId = "${var.organization_repo_name}/${each.value.application_repo_name}"
        BranchName       = each.value.branchName
      }
    }
  }

  stage {
    name = "Build"
    for_each = var.applications_details

    action {
      name             = each.value.application_name
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output_${each.value.application_name}"]
      output_artifacts = ["build_output_${each.value.application_name}"]
      version          = "1"

      configuration = {
        ProjectName   = "${each.value.application_name}_Build"
        PrimarySource = "source_output_${each.value.application_name}"
        EnvironmentVariables = jsonencode(each.value.application_codebuild_env_variables)
      }
    }
  }

  stage {
    name = "Deploy"
    for_each = var.applications_details
    action {
      name = each.value.application_name
      category = "Deploy"
      owner = "AWS"
      provider = "ECS"
      input_artifacts = [ "build_output_${each.value.application_name}" ]
      version = "1"
      configuration = {
        ClusterName = each.value.application_cluster_name
        ServiceName = each.value.application_service_name
        DeploymentTimeout = each.value.application_deployment_timeout
      }
    }
  }
}
