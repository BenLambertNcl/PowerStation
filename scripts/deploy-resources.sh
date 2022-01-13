#!/bin/bash

set -eo pipefail

BUCKET_NAME=$(aws s3api list-buckets | jq -r '.Buckets[] | select(.Name | contains("data-generator")) | .Name')

if [[ -z "$BUCKET_NAME" ]]; then
  echo "Could not find bucket name for data generator"
  exit 1
fi

rm -rf build/ || true
mkdir -p build

cp -r ../spark/tables build/tables
cp ../spark/main.py build/main.py
cp ../spark/requirements-no-pyspark.txt build/requirements.txt
cp setup.sh build/setup.sh

aws s3 sync build/ s3://$BUCKET_NAME --exclude 'build/venv/*' --exclude 'build/dependencies/*'
