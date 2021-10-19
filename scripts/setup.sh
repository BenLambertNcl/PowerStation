#!/bin/bash

set -eo pipefail

BUCKET_NAME=${1}

cd /home/hadoop

aws s3 cp s3://$BUCKET_NAME/requirements.txt requirements.txt

echo "Installing Dependencies"
pip3 install -r requirements.txt -t dependencies

echo "Building EMR resources"
cd dependencies
zip -r ../dependencies.zip .
cd ..
