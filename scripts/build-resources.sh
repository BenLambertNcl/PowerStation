#!/bin/bash

set -eo pipefail

PATH="$PATH:/usr/local/bin"

rm -rf build/ || true
mkdir build/

cp -r ../spark/ build/

pushd build/ || exit 1
  echo "Creating venv"
  python3 -m venv venv
  . "$(pwd)/venv/bin/activate"

  echo "Installing Dependencies"
  pip3 install -r requirements.txt

  echo "Building EMR resources"
  venv-pack -o pyspark_venv.tar.gz

  echo "Cleaning up"
  deactivate
  rm -rf build/venv
popd || exit 1
