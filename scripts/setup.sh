#!/bin/bash

set -eo pipefail

BUCKET_NAME=${1}

cd /home/hadoop

aws s3 cp s3://$BUCKET_NAME/requirements.txt requirements.txt

echo "Installing Dependencies"
sudo pip3 install -r requirements.txt
