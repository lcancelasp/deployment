#!/bin/bash

set -e

[[ $# -eq 0 ]] && exit 2

APPLICATION_STACK_NAME="serverless-app"
token=XXXXXXXXXXXXXXXX

aws cloudformation create-stack  --stack-name "${APPLICATION_STACK_NAME}-image-build" \
--capabilities CAPABILITY_IAM \
--template-body file://infrastructure/image-cfn.yml --parameters ParameterKey=GitHubToken,ParameterValue="${token}" \
ParameterKey=GitHubUser,ParameterValue="lcancelasp" ParameterKey=GitHubRepository,ParameterValue="deployment" \
ParameterKey=GitHubBranch,ParameterValue="studentX"

aws cloudformation wait stack-create-complete \
  --stack-name ${APPLICATION_STACK_NAME}-image-build

CODE_BUILD_IMAGE=$(aws cloudformation list-exports \
  --query "Exports[?Name==\`ServerlessAppBuildImage\`].Value" \
  --output text)

aws cloudformation create-stack \
  --stack-name "${APPLICATION_STACK_NAME}-build" \
  --capabilities CAPABILITY_IAM  \
  --template-body file://infrastructure/app-build-cfn.yml \
  --parameters ParameterKey=GitHubToken,ParameterValue="${token}" \
ParameterKey=GitHubUser,ParameterValue="lcancelasp" \
ParameterKey=GitHubRepository,ParameterValue="deployment" \
ParameterKey=GitHubBranch,ParameterValue="studentX" \
ParameterKey=CodeBuildImage,ParameterValue=${CODE_BUILD_IMAGE}
