

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