#!/bin/bash

set -eo pipefail
CLUSTER_ID=$(aws emr list-clusters | jq -r '.Clusters[] | select(.Status.State == "WAITING") | .Id')
BUCKET_NAME=$(aws s3api list-buckets | jq -r '.Buckets[] | select(.Name | contains("data-generator")) | .Name')

if [[ -z "$BUCKET_NAME" || -z "$CLUSTER_ID" ]]; then
  echo "Could not find running cluster or the bucket containing your script"
  exit 1
fi

aws emr add-steps \
  --no-cli-pager \
  --cluster-id $CLUSTER_ID \
  --steps Type=CUSTOM_JAR,Name=Generate,ActionOnFailure=CONTINUE,Jar=command-runner.jar,Args=spark-submit,s3://$BUCKET_NAME/main.py,s3://$BUCKET_NAME/tables,s3://$BUCKET_NAME/output
