#!/bin/bash

set -eo pipefail

CLUSTER_ID=${1}
BUCKET_NAME=${2}

aws emr add-steps --cluster-id $CLUSTER_ID \
  --steps Type=CUSTOM_JAR,Name=CustomJAR,ActionOnFailure=CONTINUE,Jar=command-runner.jar,Args=spark-submit,--archives,s3://$BUCKET_NAME/pyspark_venv.tar.gz,s3://$BUCKET_NAME/main.py,s3://$BUCKET_NAME/tables,s3://$BUCKET_NAME/output
