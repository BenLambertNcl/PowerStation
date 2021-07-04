#!/bin/bash

set -eo pipefail

BUCKET_NAME=${1}

pwd

aws s3 sync "s3://${BUCKET_NAME}/build" .
