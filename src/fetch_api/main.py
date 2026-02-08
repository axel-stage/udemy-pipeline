"""
AWS Lambda function to request the Udemy API for course data and persist it to S3
"""

import json
import time
import logging
from typing import Any, TypedDict

import requests
import boto3
from botocore.exceptions import ClientError


BASE_URL = "https://www.udemy.com/api-2.0"
HEADERS = {"Accept": "application/json"}
TIMEOUT = 10

logger = logging.getLogger()
logger.setLevel(logging.INFO)

s3 = boto3.client("s3")


class LambdaEvent(TypedDict):
    """
    Schema for incoming Lambda events.

    Attributes:
        course_id: course identifier
        bucket: Target S3 bucket for storing results.
        prefix: S3 key prefix (folder path).
    """
    course_id: str
    bucket: str
    prefix: str


def current_date() -> str:
    """
    Return the current date in ISO format (YYYY-MM-DD).

    Returns:
        Current UTC date as a string.
    """
    return time.strftime("%Y-%m-%d")


def make_s3_key(prefix: str, course_id: str) -> str:
    """
    Generate the S3 object key for the payload.

    Format:
        {prefix}/api_{course_id}_{current_date}.json

    Args:
        prefix: S3 prefix (folder path).
        course_id: Course Identifier

    Returns:
        Fully qualified S3 object key.
    """
    return f'{prefix}api_{course_id}_{current_date()}.json'


# side effect
def fetch_api(url: str) -> dict[str, Any]:
    """
    Fetch data from the API.

    Args:
        url: URL of the resource

    Returns:
        data dict
    """
    response = requests.get(url, headers=HEADERS, timeout=TIMEOUT)
    response.raise_for_status()
    return response.json()


def upload_to_s3(bucket: str, key: str, payload: dict[str, Any]) -> None:
    """
    Upload payload as JSON to S3.

    Args:
        bucket: Target S3 bucket.
        key: Object key within the bucket.
        payload: Serialized course payload.

    Raises:
        ClientError: If S3 upload fails.
    """
    s3.put_object(
        Bucket=bucket,
        Key=key,
        Body=json.dumps(payload).encode(),
    )


def lambda_handler(event: LambdaEvent, context: object) -> None:
    """
    AWS Lambda entry point.

    Orchestrates the full scraping pipeline:
        - Fetch API
        - Upload to S3

    Args:
        event: LambdaEvent containing input parameters.
        context: AWS Lambda runtime context.

    Raises:
        requests.RequestException: On HTTP failures.
        ClientError: On S3 upload failures.
    """
    logger.info("Start lambda")

    course_id = event["course_id"]
    bucket = event["bucket"]
    prefix = event["prefix"]

    try:
        url = f"{BASE_URL}/courses/{course_id}/"
        data = fetch_api(url)
        key = make_s3_key(prefix, course_id)
        upload_to_s3(bucket, key, data)

        logger.info("Fetch data: %s", data)
        logger.info("Uploaded to s3://%s/%s", bucket, key)

    except (requests.RequestException, ClientError) as error:
        logger.error("Processing failed: %s", error)
        raise error

    finally:
        logger.info("Stop lambda")
        logger.info("#" * 80)
