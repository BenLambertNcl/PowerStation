# WIP: PowerStation
A work in progress, big data generator using Apache Spark, capable of generating massive amounts of relational data

## Usage
At the moment, this is a WIP, so to generate the test data locally, run 
```
pip3 install -r requirements.txt
python3 main.py
```

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
- `"count"` - (Required) The number of rows to generate
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

## TODO
- Create infra to run on cloud (AWS EMR)
- Allow more configurability via cli
- Externalise configuration
