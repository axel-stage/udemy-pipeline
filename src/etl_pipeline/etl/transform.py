import duckdb
from pathlib import Path


def run_sql(con, path):
    con.execute(Path(path).read_text())


def transform_data(db_path: str):
    with duckdb.connect(db_path) as con:
        run_sql(con, "src/etl_pipeline/sql/bronze.sql")
        run_sql(con, "src/etl_pipeline/sql/silver.sql")
        run_sql(con, "src/etl_pipeline/sql/gold.sql")
