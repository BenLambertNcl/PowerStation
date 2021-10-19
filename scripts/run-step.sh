#!/bin/bash

set -eo pipefail

CLUSTER_ID=${1}
BUCKET_NAME=${2}

if [[ -z "$BUCKET_NAME" || -z "$CLUSTER_ID}" ]]; then
  echo "Usage: deploy-resources.sh <CLUSTER_ID> <BUCKET_NAME>"
  exit 1
fi

aws emr add-steps \
  --no-cli-pager \
  --cluster-id $CLUSTER_ID \
  --steps Type=CUSTOM_JAR,Name=Copy-Files,ActionOnFailure=CONTINUE,Jar=command-runner.jar,Args=aws,s3,cp,s3://$BUCKET_NAME/setup.sh,/home/hadoop/setup.sh

aws emr add-steps \
  --no-cli-pager \
  --cluster-id $CLUSTER_ID \
  --steps Type=CUSTOM_JAR,Name=Run-Setup,ActionOnFailure=CONTINUE,Jar=command-runner.jar,Args=bash,-c,"chmod +x /home/hadoop/setup.sh && /home/hadoop/setup.sh $BUCKET_NAME"

aws emr add-steps \
  --no-cli-pager \
  --cluster-id $CLUSTER_ID \
  --steps Type=CUSTOM_JAR,Name=Generate,ActionOnFailure=CONTINUE,Jar=command-runner.jar,Args=spark-submit,--py-files,/home/hadoop/dependencies.zip,s3://$BUCKET_NAME/main.py,s3://$BUCKET_NAME/tables,s3://$BUCKET_NAME/output
