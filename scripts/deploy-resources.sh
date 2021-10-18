#!/bin/bash

set -eo pipefail

BUCKET_NAME=${1}

aws s3 sync build/ $BUCKET_NAME
