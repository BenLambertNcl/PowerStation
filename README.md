# WIP: PowerStation
A work in progress, big data generator using Apache Spark, capable of generating massive amounts of relational data

## Requirements
- 🐍 Python3
- ☕ Java 1.8
- 🏗️ Terraform

## Usage
At the moment, this is a WIP, so to generate the test data locally, run 
```bash
cd spark

# Setup Python env
python3 -m venv venv
. venv/bin/activate
pip3 install -r requirements.txt

spark-submit --master "local[*]" \
  main.py \
  $(pwd)/tables \
  $(pwd)/output \
  powerstation.json
```

## Deployment
In the future, the generator should be able to run on any spark cluster, but for now only the EMR cluster
created using the terraform in this repo is supported. To deploy to the running cluster use the scripts
in the `/scripts` directory

## Definition Files
The definition files are written in JSON, which can be seen in the 
`tables` directory. The different sections are as follows:
- powerstation.json
    - The meta file. Used to coordinate and configure the generator itself
- table.json
    - A file to configure a specific table
    
## Table Configuration
The table config files contain the following propeties:
- `"name"` - (Optional) The name of the table
- `"columns"` - (Required) Array of object to generate
  - `"name"` - (Required) Name of the column
  - `"type"` - (Required) Faker type to generate
- `"join_with"` - (Optional) List of tables to join on. When joining tables, the columns of the joined tables 
    are prefixed with the name of the table (i.e. `car_make` for the `make` column in the `car` table)
- `"output_columns"` - (Required) List of objects configuring the output
  - `"name"` - (Required) The name of the output column (including table prefix, if from a join)
  - `"as"` - (Optional) Used to rename the column in the output
- `"scd"` - (Optional) Configures the table to be a slowly changing dimention
    - `"ratio"` - (Required) A ratio of rows to "change" in the SCD (must be in the format 1:x)
    - `"from_col"` - (Required) The name of the column to use ad the from timestamp
    - `"to_col"` - (Required) The name of the column to use ad the to timestamp
    - `"current_col"` - (Optional) The name of the column to use as a boolean flag to show if the row is the current row
- `"output_file_partitions"` - (Optional) The number of partitions to use when writing each table
- `"output_format"` - (Optional) The format to write the output files in `[json, csv]`

## TODO
- Allow more configurability via cli
- Externalise configuration
- Fix startup issues with cluster
- Test performance
- Create a CLI tool to perform setup etc
