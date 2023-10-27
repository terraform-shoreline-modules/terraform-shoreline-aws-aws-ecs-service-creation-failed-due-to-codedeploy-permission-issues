#!/bin/bash



APPLICATION_NAME=${APPLICATION_NAME}



#List CodeDeploy deployment groups for a specified application



deployment_groups=$(aws deploy list-deployment-groups --application-name $APPLICATION_NAME --query "deploymentGroups[]" --output text)



#Get last attempted deployment id



deployment_id=$(aws deploy get-deployment-group --application-name $APPLICATION_NAME --deployment-group-name $DEPLOYMENT_GROUP_ID --query "deploymentGroupInfo.lastAttemptedDeployment.deploymentId" --output text)



#Get the details of the CodeDeploy deployment 

aws deploy get-deployment --deployment-id $deployment_id