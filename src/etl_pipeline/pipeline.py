import yaml

from etl.extract import extract_data
from etl.transform import transform_data
from etl.load import load_data

with open("src/etl_pipeline/config.yaml", "r") as file:
    config = yaml.safe_load(file)

WAREHOUSE_PATH = "src/etl_pipeline/warehouse.duckdb"
TABLE_NAME = config["database"]["table_name"]
BUCKET_NAME = config["bucket"]["name"]
CERT_PREFIX = config["bucket"]["prefix_certificate"]
API_PREFIX = config["bucket"]["prefix_api"]

def run_pipeline():
    extract_data(BUCKET_NAME, API_PREFIX, "api")
    extract_data(BUCKET_NAME, CERT_PREFIX, "certificate")
    transform_data(WAREHOUSE_PATH)
    query = "select * from gold.owner_stats;"
    load_data(WAREHOUSE_PATH, TABLE_NAME, query)

if __name__ == "__main__":
    run_pipeline()
