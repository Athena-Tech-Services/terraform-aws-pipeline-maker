variable "region" {
  type        = string
  default     = "eu-west-1"
  description = "The region for the AWS resources"
}

variable "organization_repo_name" {
  type        = string
  description = "The org and repo for the deployment"
}

variable "applications_details" {
  type = map(object({
    application_cluster_name       = string
    application_service_name       = string
    application_deployment_timeout = string
    application_name               = string
    application_repo_name          = string
    branchName                     = string
    application_codebuild_env_variables = list(object({
      name  = string
      value = string
      type  = string
    }))
  }))
  description = "Application details for each application"
}

variable "vpc_custom" {
  type        = string
  description = "The id of the vpc"
}
