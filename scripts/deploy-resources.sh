#!/bin/bash

set -eo pipefail

BUCKET_NAME=${1}

if [[ -z "$BUCKET_NAME" ]]; then
  echo "Usage: deploy-resources.sh <BUCKET_NAME>"
  exit 1
fi

rm -rf build/ || true
mkdir -p build

cp -r ../spark/tables build/tables
cp ../spark/main.py build/main.py
cp ../spark/requirements.txt build/requirements.txt
cp setup.sh build/setup.sh

aws s3 sync build/ s3://$BUCKET_NAME --exclude 'build/venv/*' --exclude 'build/dependencies/*'
