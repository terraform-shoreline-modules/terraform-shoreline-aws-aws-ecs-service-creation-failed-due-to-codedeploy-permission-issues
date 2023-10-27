
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# AWS CodeDeploy IAM role permission issue for ECS Service creation.
---

This incident type refers to the issue faced while creating an Amazon ECS Service due to the error message "Please create your Service role for CodeDeploy". This error occurs because AWS CodeDeploy does not have the required IAM permissions to perform the blue/green deployment strategy. To resolve this, the CodeDeploy service needs to be granted the necessary permissions to update the Amazon ECS service. The incident typically requires troubleshooting by verifying the CodeDeploy IAM role and ensuring it has the required permissions.

### Parameters
```shell
export APPLICATION_NAME="PLACEHOLDER"

export CODEDEPLOY_IAM_ROLE_NAME="PLACEHOLDER"
```

## Debug

### List CodeDeploy applications
```shell
aws deploy list-applications
```

### Describe an IAM role
```shell
aws iam get-role --role-name ${CODEDEPLOY_IAM_ROLE_NAME}
```

### Get the details of the CodeDeploy deployment
```shell
#!/bin/bash



APPLICATION_NAME=${APPLICATION_NAME}



#List CodeDeploy deployment groups for a specified application



deployment_groups=$(aws deploy list-deployment-groups --application-name $APPLICATION_NAME --query "deploymentGroups[]" --output text)



#Get last attempted deployment id



deployment_id=$(aws deploy get-deployment-group --application-name $APPLICATION_NAME --deployment-group-name $DEPLOYMENT_GROUP_ID --query "deploymentGroupInfo.lastAttemptedDeployment.deploymentId" --output text)



#Get the details of the CodeDeploy deployment 

aws deploy get-deployment --deployment-id $deployment_id
```


### Verify that the CodeDeploy IAM role is created correctly and has the required permissions to update the Amazon ECS service.
```shell


#!/bin/bash



ROLE_NAME=${CODEDEPLOY_IAM_ROLE_NAME}





ALL_POLICIES=$(aws iam list-attached-role-policies --role-name $ROLE_NAME --query "AttachedPolicies[].PolicyArn" --output text --profile synthetic-acumen-prod )

INLINE_POLICIES=$(aws iam list-role-policies --role-name $ROLE_NAME --query "PolicyNames[]" --output text --profile synthetic-acumen-prod)



for POLICY in $ALL_POLICIES; do

    aws iam get-policy-version --policy-arn $POLICY --version-id v1 --query "PolicyVersion.Document" --output json --profile synthetic-acumen-prod

done



for POLICY_NAME in $INLINE_POLICIES; do

    aws iam get-role-policy --role-name $ROLE_NAME --policy-name $POLICY_NAME --query "PolicyDocument" --output json --profile synthetic-acumen-prod

done
```

## Repair

### Attach the necessary IAM permissions to perform the blue/green deployment strategy to the CodeDeploy service.
```shell


#!/bin/bash



# Set variables

CODEDEPLOY_IAM_ROLE_NAME=${CODEDEPLOY_IAM_ROLE_NAME}



# Create a new IAM policy for CodeDeploy

echo '{

    "Version": "2012-10-17",

    "Statement": [

        {

            "Effect": "Allow",

            "Action": [

                "ecs:DescribeServices",

                "ecs:CreateTaskSet",

                "ecs:UpdateServicePrimaryTaskSet",

                "ecs:DeleteTaskSet",

                "elasticloadbalancing:DescribeTargetGroups",

                "elasticloadbalancing:DescribeListeners",

                "elasticloadbalancing:ModifyListener",

                "elasticloadbalancing:DescribeRules",

                "elasticloadbalancing:ModifyRule",

                "lambda:InvokeFunction",

                "cloudwatch:DescribeAlarms",

                "sns:Publish",

                "s3:GetObject",

                "s3:GetObjectVersion"

            ],

            "Resource": "*"

        }

    ]

}' > CodeDeploy_ECS_policy.json







# Create the new IAM policy and get the ARN

POLICY_ARN=$(aws iam create-policy --policy-name CodeDeploy_ECS_policy --policy-document file://CodeDeploy_ECS_policy.json --query 'Policy.Arn' --output text)



# Attach the new policy to the CodeDeploy service role

aws iam attach-role-policy --role-name $CODEDEPLOY_IAM_ROLE_NAME --policy-arn $POLICY_ARN




```