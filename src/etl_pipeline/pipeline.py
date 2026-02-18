import yaml
import logging
from pathlib import Path

from config import CONFIG_PATH, DATA_PATH, WAREHOUSE_PATH, OWNER_STATS_QUERY, OWNER_STATS_MAPPING, INSTRUCTOR_TOP_5_QUERY, INSTRUCTOR_TOP_5_MAPPING
from etl.extract import extract_data
from etl.transform import transform_data
from etl.load import load_data


logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)


def load_config(config_path: str) -> dict:
    """
    Load pipeline configuration from YAML.

    Returns:
        Parsed configuration dictionary.

    Raises:
        FileNotFoundError: If config file is missing.
    """
    config_file = Path(config_path)

    with open(config_file, "r") as file:
        return yaml.safe_load(file)


def run_pipeline() -> None:
    """
    Execute the full ELT pipeline:

    1. Extract raw JSON from S3
    2. Transform data in DuckDB (Bronze → Silver → Gold)
    3. Load Gold aggregates into DynamoDB

    This function acts as the main orchestration entry point
    (e.g. Lambda handler or CLI runner).

    Raises:
        Exception: Propagates any pipeline failure.
    """
    logger.info("Pipeline started")

    config = load_config(CONFIG_PATH)
    TABLE_NAME = config["database"]["table_name"]
    BUCKET_NAME = config["bucket"]["name"]
    CERT_PREFIX = config["bucket"]["prefix_certificate"]
    API_PREFIX = config["bucket"]["prefix_api"]

    try:
        # Extract
        extract_data(BUCKET_NAME, API_PREFIX, DATA_PATH, "api")
        logger.info("Extracted data from: %s/%s", BUCKET_NAME, API_PREFIX)
        extract_data(BUCKET_NAME, CERT_PREFIX, DATA_PATH, "certificate")
        logger.info("Extracted data from: %s/%s", BUCKET_NAME, CERT_PREFIX)

        # Transform
        transform_data(WAREHOUSE_PATH)
        logger.info("Transformed data with local warehouse: %s", WAREHOUSE_PATH)

        # Load
        load_data(
            WAREHOUSE_PATH,
            TABLE_NAME,
            OWNER_STATS_QUERY,
            OWNER_STATS_MAPPING,
        )
        logger.info("Loaded owner data into DynamoDB table: %s", TABLE_NAME)
        load_data(
            WAREHOUSE_PATH,
            TABLE_NAME,
            INSTRUCTOR_TOP_5_QUERY,
            INSTRUCTOR_TOP_5_MAPPING,
        )
        logger.info("Loaded instructor data into DynamoDB table: %s", TABLE_NAME)

    except Exception:
        logger.exception("Pipeline failed")
        raise

    finally:
        logger.info("Pipeline finished")


if __name__ == "__main__":
    run_pipeline()
