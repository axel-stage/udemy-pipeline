import os
import logging
from dotenv import load_dotenv

from config import (
    ROOT_DIR,
    MODULE_DIR,
    STORAGE_DIR,
    WAREHOUSE_PATH,
    OWNER_STATS_QUERY,
    OWNER_STATS_MAPPING,
    INSTRUCTOR_TOP_5_QUERY,
    INSTRUCTOR_TOP_5_MAPPING
)
from etl.extract import extract_data
from etl.transform import transform_data
from etl.load import load_data


logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)

load_dotenv(dotenv_path=f"{ROOT_DIR}/.env")
TABLE_NAME = os.getenv("TABLE_NAME")
BUCKET_NAME = os.getenv("BUCKET_NAME")
CERTIFICATE_PREFIX = os.getenv("CERTIFICATE_PREFIX")
API_PREFIX = os.getenv("API_PREFIX")


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

    try:
        # Extract
        extract_data(BUCKET_NAME, API_PREFIX, STORAGE_DIR, "api")
        logger.info("Extracted data from: %s/%s", BUCKET_NAME, API_PREFIX)
        extract_data(BUCKET_NAME, CERTIFICATE_PREFIX, STORAGE_DIR, "certificate")
        logger.info("Extracted data from: %s/%s", BUCKET_NAME, CERTIFICATE_PREFIX)

        # Transform
        transform_data(WAREHOUSE_PATH, MODULE_DIR)
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
