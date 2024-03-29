#!/bin/bash

# Author: MrBiTs (mrbits@mrbits.com.br)
# Date: 2021-12-05 (Stardate 99527.37)
#
# Script to deploy entire base structure,
# with S3 buckets to store tfstate files
# and DynamoDB table to lock state.
#
# AWS credentials must be set already.

. ./lib/common.sh

date_msg "Starting Terraform project configuration"

TIMESTAMP=$(date +%F-%T)

KEY_NAME="remote-state-terraform" # remote state filename
PREFIX="laf-remote-state-bootstrap"  # remote state project name
MAIN_PROJECT="laf-terraform-state"
PEP="coem001"
CREATE_IAM_USER=0
PROFILE="logicalis-aws-br"

if [ "${KEYNAME}" == "INVALID" ] || [ "${PREFIX}" == "INVALID" ]; then
  date_msg "Please configure KEYNAME and PREFIX variables in this script"
  exit 255
fi

[[ $PROFILE ]] && AWSCLI_EXTRA_OPTS="--profile $PROFILE"

AWS_ID=$(aws sts get-caller-identity)
ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' $AWSCLI_EXTRA_OPTS --out text)
[[ $AWS_REGION ]] || AWS_REGION=sa-east-1
BUCKET_NAME="${PREFIX}-${AWS_REGION}-${ACCOUNT_ID}"

aws s3 ls s3://${BUCKET_NAME} --region=${AWS_REGION} >/dev/null 2>&1

if [ $? -gt 0 ] ; then
  date_msg "Creating S3 Bucket ${BUCKET_NAME} into Account ${ACCOUNT_ID} for remote_state IaC."
  aws s3 mb s3://${BUCKET_NAME} --region=${AWS_REGION}
fi

date_msg "Creating remote state Terraform provider/backend files."

cd remote_state

echo ${BUCKET_NAME} > .remote_state_bucket
rm -rf .terraform .terraform.lock.hcl tfplan

for FILE in *.jinja2; do
    DEST_FILE=$(basename $FILE .jinja2).tf
    date_msg "Creating $DEST_FILE from $FILE"
    jinja2 $FILE \
      -D timestamp="$TIMESTAMP" \
      -D aws_region=$AWS_REGION \
      -D bucket_name=$BUCKET_NAME \
      -D key_name=$KEY_NAME \
      -D account_id=$ACCOUNT_ID \
      -D prefix=$PREFIX \
      -D main_project=$MAIN_PROJECT \
      -D pep=$PEP \
      -o ./$DEST_FILE 1>/dev/null 2>&1
done

date_msg "Run remote state bucket/DynamoDB table preparation"

[[ $CREATE_IAM_USER == 1 ]] || TF_EXTRA_OPTIONS=-var="create_iam_service_user=true"

terraform fmt
terraform init
terraform plan ${TF_EXTRA_OPTIONS} -out tfplan
terraform apply -auto-approve tfplan

DYNAMODB_TABLE=$(terraform output dynamodb-lock-table)
TFSTATE_BUCKET_NAME=$(terraform output s3-state-bucket)

cd ..

echo ""
date_msg "Creating root Terraform provider/backend files."

rm -rf .terraform .terraform.lock.hcl tfplan

for FILE in *.jinja2; do
    DEST_FILE=$(basename $FILE .jinja2).tf
    date_msg "Creating $DEST_FILE from $FILE"
    jinja2 $FILE \
      -D timestamp="$TIMESTAMP" \
      -D aws_region=$AWS_REGION \
      -D bucket_name=$TFSTATE_BUCKET_NAME \
      -D prefix=$PEP \
      -D dynamodb_table=$DYNAMODB_TABLE \
      -o ./$DEST_FILE 1>/dev/null 2>&1
done

terraform fmt
date_msg "Terraform project configured"

