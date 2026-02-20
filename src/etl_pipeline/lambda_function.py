"""
AWS Lambda function to run the ETL pipeline
"""

import logging
from typing import TypedDict

from config import (
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


class LambdaEvent(TypedDict):
    """
    Schema for incoming Lambda events.
    """
    table_name: str
    bucket_name: str
    prefix_certificate: str
    prefix_api: str


def lambda_handler(event: LambdaEvent, context: object) -> None:
    """
    AWS Lambda entry point, orchestrates the ETL pipeline:
        1. Extract raw JSON from S3
        2. Transform data in DuckDB (Bronze → Silver → Gold)
        3. Load Gold aggregates into DynamoDB

    Args:
        event: LambdaEvent containing input parameters.
        context: AWS Lambda runtime context.

    Raises:
        Exception: Propagates any ETL pipeline failure.
    """

    TABLE_NAME = event["TABLE_NAME"]
    BUCKET_NAME = event["BUCKET_NAME"]
    PREFIX_UPSTREAM_CERTIFICATE = event["PREFIX_UPSTREAM_CERTIFICATE"]
    PREFIX_UPSTREAM_API = event["PREFIX_UPSTREAM_API"]
    FILE_NAME_API = "api"
    FILE_NAME_CERTIFICATE = "certificate"

    logger.info("Pipeline started")

    try:
        # Extract
        extract_data(BUCKET_NAME, PREFIX_UPSTREAM_API, STORAGE_DIR, FILE_NAME_API)
        logger.info("Extracted data from: %s/%s", BUCKET_NAME, PREFIX_UPSTREAM_API)
        extract_data(BUCKET_NAME, PREFIX_UPSTREAM_CERTIFICATE,  STORAGE_DIR, FILE_NAME_CERTIFICATE )
        logger.info("Extracted data from: %s/%s", BUCKET_NAME, PREFIX_UPSTREAM_CERTIFICATE)

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

    except Exception as error:
        logger.exception("Pipeline failed: %s", error)
        raise error

    finally:
        logger.info("Pipeline finished")
