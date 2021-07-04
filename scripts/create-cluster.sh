#!/bin/bash

set -eo pipefail

RANDOM_TEXT=$(head /dev/urandom | LC_ALL=C tr -dc a-z | head -c10)
BUCKET_NAME="powerstation-resources-$(aws sts get-caller-identity | jq -r '.Account')"

export AWS_REGION="eu-west-2"
export AWS_PAGER=""

echo "Creating Bucket"
aws s3api create-bucket --bucket "$BUCKET_NAME" --acl "private" --create-bucket-configuration "LocationConstraint=eu-west-2"

./build-resources.sh

aws s3 cp bootstrap.sh "s3://${BUCKET_NAME}/bootstrap.sh"
aws s3 sync build/ "s3://${BUCKET_NAME}/build"

echo "Creating Cluster"
aws emr create-default-roles
aws emr create-cluster \
    --name "powerstation-${RANDOM_TEXT}" \
    --applications Name=Spark \
    --release-label emr-6.3.0 \
    --instance-type m4.large \
    --instance-count 2 \
    --visible-to-all-users \
    --bootstrap-actions "Path=s3://${BUCKET_NAME}/bootstrap.sh,Args=${BUCKET_NAME}" \
    --use-default-roles \
    --auto-terminate \
    --steps "Type=CUSTOM_JAR,ActionOnFailure=TERMINATE_CLUSTER,Jar=command-runner.jar,Args=spark-submit,--archives,s3://${BUCKET_NAME}/build/pyspark_venv.tar.gz,s3://${BUCKET_NAME}/build/main.py,s3://${BUCKET_NAME}/build/tables,s3://${BUCKET_NAME}/output"
