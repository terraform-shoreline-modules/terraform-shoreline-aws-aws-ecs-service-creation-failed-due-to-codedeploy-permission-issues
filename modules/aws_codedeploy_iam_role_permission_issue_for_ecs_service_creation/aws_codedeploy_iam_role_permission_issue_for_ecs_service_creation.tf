resource "shoreline_notebook" "aws_codedeploy_iam_role_permission_issue_for_ecs_service_creation" {
  name       = "aws_codedeploy_iam_role_permission_issue_for_ecs_service_creation"
  data       = file("${path.module}/data/aws_codedeploy_iam_role_permission_issue_for_ecs_service_creation.json")
  depends_on = [shoreline_action.invoke_list_dep_groups_last_dep_details,shoreline_action.invoke_policies_script,shoreline_action.invoke_create_iam_policy]
}

resource "shoreline_file" "list_dep_groups_last_dep_details" {
  name             = "list_dep_groups_last_dep_details"
  input_file       = "${path.module}/data/list_dep_groups_last_dep_details.sh"
  md5              = filemd5("${path.module}/data/list_dep_groups_last_dep_details.sh")
  description      = "Get the details of the CodeDeploy deployment"
  destination_path = "/tmp/list_dep_groups_last_dep_details.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "policies_script" {
  name             = "policies_script"
  input_file       = "${path.module}/data/policies_script.sh"
  md5              = filemd5("${path.module}/data/policies_script.sh")
  description      = "Verify that the CodeDeploy IAM role is created correctly and has the required permissions to update the Amazon ECS service."
  destination_path = "/tmp/policies_script.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "create_iam_policy" {
  name             = "create_iam_policy"
  input_file       = "${path.module}/data/create_iam_policy.sh"
  md5              = filemd5("${path.module}/data/create_iam_policy.sh")
  description      = "Attach the necessary IAM permissions to perform the blue/green deployment strategy to the CodeDeploy service."
  destination_path = "/tmp/create_iam_policy.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_list_dep_groups_last_dep_details" {
  name        = "invoke_list_dep_groups_last_dep_details"
  description = "Get the details of the CodeDeploy deployment"
  command     = "`chmod +x /tmp/list_dep_groups_last_dep_details.sh && /tmp/list_dep_groups_last_dep_details.sh`"
  params      = ["APPLICATION_NAME"]
  file_deps   = ["list_dep_groups_last_dep_details"]
  enabled     = true
  depends_on  = [shoreline_file.list_dep_groups_last_dep_details]
}

resource "shoreline_action" "invoke_policies_script" {
  name        = "invoke_policies_script"
  description = "Verify that the CodeDeploy IAM role is created correctly and has the required permissions to update the Amazon ECS service."
  command     = "`chmod +x /tmp/policies_script.sh && /tmp/policies_script.sh`"
  params      = ["CODEDEPLOY_IAM_ROLE_NAME"]
  file_deps   = ["policies_script"]
  enabled     = true
  depends_on  = [shoreline_file.policies_script]
}

resource "shoreline_action" "invoke_create_iam_policy" {
  name        = "invoke_create_iam_policy"
  description = "Attach the necessary IAM permissions to perform the blue/green deployment strategy to the CodeDeploy service."
  command     = "`chmod +x /tmp/create_iam_policy.sh && /tmp/create_iam_policy.sh`"
  params      = ["CODEDEPLOY_IAM_ROLE_NAME"]
  file_deps   = ["create_iam_policy"]
  enabled     = true
  depends_on  = [shoreline_file.create_iam_policy]
}

