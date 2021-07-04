import datetime
from typing import Callable

from pyspark.sql import SparkSession, Row, DataFrame
from pyspark.sql.functions import col
from faker import Faker
import numpy.random as rd
import json
import sys


def create_row(row_num, max_rows, config):
    fake = Faker()
    rows = []
    row = {
        "row_num": row_num
    }

    for column in config["columns"]:
        params = column.get("params", {})
        faker_method = getattr(fake, column["type"])
        row[column["name"]] = faker_method(**params)

    if config.get("scd", None):
        scd = config["scd"]
        from_col = scd["from_col"]
        to_col = scd["to_col"]
        ratio = scd["ratio"]
        current_col = scd.get("current_col", None)
        start_date = datetime.datetime(2010, 1, 1) + datetime.timedelta(days=rd.randint(1, 2000))
        row[from_col] = start_date.isoformat()
        row[to_col] = datetime.datetime(9999, 12, 31).isoformat()
        if current_col:
            row[current_col] = True

        if row_num % int(ratio.split(":")[1]) == 0:
            scd_row = row.copy()
            scd_row["row_num"] = max_rows + (max_rows // row_num)

            scd_start_date = start_date + datetime.timedelta(days=rd.randint(1, 2000))
            row[to_col] = scd_start_date.isoformat()
            scd_row[from_col] = scd_start_date.isoformat()
            scd_row[to_col] = datetime.datetime(9999, 12, 31).isoformat()

            if current_col:
                row[current_col] = False
                scd_row[current_col] = True

            rows.append(scd_row)

        rows.append(Row(**row))
    else:
        rows.append(Row(**row))

    return rows


def join_dataframes(spark, join_table, df, meta_config):
    joining_df = spark.read.json(f'{output_location}/{join_table}')
    joining_df_with_renamed_cols = joining_df.select([col(c).alias(join_table + "_" + c) for c in joining_df.columns])
    joining_rows = list(filter(lambda table: table["filename"] == join_table, meta_config["tables"]))[0]["rows"]
    create_join_col: Callable[[Row], Row] = lambda row: Row(**{**(row.asDict()), "joining_id": rd.randint(1, joining_rows + 1)})
    df_with_joining_col = df.rdd.map(create_join_col).toDF()
    return df_with_joining_col.join(joining_df_with_renamed_cols,
                                    col("joining_id") == col(f"{join_table}_row_num"),
                                    'left')


def generate(spark: SparkSession, config, meta_config):
    output_columns = ["row_num"] + list(map(lambda column: column["name"], config["output_columns"]))
    rows = list(filter(lambda table: table["filename"] == config["name"], meta_config["tables"]))[0]["rows"]

    df: DataFrame = spark.range(1, rows + 1).withColumnRenamed("id", "row_num") \
        .rdd.flatMap(lambda row: create_row(row["row_num"], rows, config)).toDF()

    for join_table in config.get("join_with", []):
        df = join_dataframes(spark, join_table, df, meta_config)

    df = df.select(output_columns)

    for column in filter(lambda col: col.get("as", None) is not None, config["output_columns"]):
        df = df.withColumnRenamed(column["name"], column["as"])

    df.coalesce(meta_config["output_file_partitions"]).write.mode("overwrite").option("multiline", "false").json(f'{output_location}/{config["name"]}')


if __name__ == "__main__":
    ss = SparkSession.builder \
        .appName("test").getOrCreate()

    config_location = sys.argv[1]
    output_location = sys.argv[2] or "output"

    with open(f'{config_location}/powerstation.json', 'r') as config_file:
        conf = json.load(config_file)
        for table in conf["tables"]:
            with open(f'{config_location}/{table["filename"]}.json') as table_file:
                table_config = json.load(table_file)
                generate(ss, table_config, conf)
