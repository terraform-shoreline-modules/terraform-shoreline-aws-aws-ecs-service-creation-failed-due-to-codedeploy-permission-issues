

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