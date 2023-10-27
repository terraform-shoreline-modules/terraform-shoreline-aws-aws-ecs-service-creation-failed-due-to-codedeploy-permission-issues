terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "aws_codedeploy_iam_role_permission_issue_for_ecs_service_creation" {
  source    = "./modules/aws_codedeploy_iam_role_permission_issue_for_ecs_service_creation"

  providers = {
    shoreline = shoreline
  }
}