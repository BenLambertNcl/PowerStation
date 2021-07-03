#!/bin/bash

venv-pack -o pyspark_venv.tar.gz
spark-sumbit --master "local[*]" --archives pyspark_venv.tar.gz main.py
