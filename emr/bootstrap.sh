#!/bin/bash

BUCKET_NAME=${1-}

mkdir -p /generator
aws s3 sync $BUCKET_NAME /generator


