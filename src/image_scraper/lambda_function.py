import json
from datetime import datetime, timezone
import logging
from typing import TypedDict

import boto3
from botocore.exceptions import ClientError
from image_scraper import UdemyCertificateScraper


logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)

s3_client = boto3.client("s3")


class LambdaEvent(TypedDict):
    """
    Schema for incoming Lambda events.

    Attributes:
        CERTIFICATE_ID: course identifier
        BUCKET_NAME: Target S3 bucket name for storing results.
        PREFIX_LANDING_CERTIFICATE: S3 key for unprocesses jpg certificates
        PREFIX_UPSTREAM_CERTIFICATE: S3 key for processes certificate data
    """
    CERTIFICATE_ID: str
    BUCKET_NAME: str
    PREFIX_LANDING_CERTIFICATE: str
    PREFIX_UPSTREAM_CERTIFICATE: str

def get_certificate_id(key: str) -> str:
    """
    Extract certificate_id from AWS S3 key

    Args:
        key: AWS S3 key

    Raises:
        ValueError
    """
    if not isinstance(key, str):
        raise ValueError("Key must be a str")

    if "/" in key:
        key = key.split("/")[-1]

    if ".jpg" in key:
        key = key[:-4]

    return key

def lambda_handler(event: LambdaEvent, context: object) -> None:
    """
    AWS Lambda entry point.

    Args:
        event: LambdaEvent containing input parameters.
        context: AWS Lambda runtime context.

    Raises:
        ClientError: On S3 upload failures.
        Exception: Any error
    """

    CERTIFICATE_ID: str = get_certificate_id(event["CERTIFICATE_ID"])
    BUCKET_NAME: str = event["BUCKET_NAME"]
    PREFIX_LANDING_CERTIFICATE: str = event["PREFIX_LANDING_CERTIFICATE"]
    PREFIX_UPSTREAM_CERTIFICATE: str = event["PREFIX_UPSTREAM_CERTIFICATE"]

    try:
        logger.info("Lambda started")
        download_key = f"{PREFIX_LANDING_CERTIFICATE}/{CERTIFICATE_ID}.jpg"
        local_file_name = f"/tmp/{CERTIFICATE_ID}.jpg"
        s3_client.download_file(
            Bucket=BUCKET_NAME,
            Key=download_key,
            Filename=local_file_name
        )
        logger.info(f"Download: {download_key}")
        certificate = UdemyCertificateScraper(local_file_name)
        certificate.parse_image_text()
        data = {
            "owner": certificate.get_owner(),
            "certificate_id": certificate.get_certificate_id(),
            "instructors": certificate.get_instructors(),
            "title": certificate.get_title(),
            "course_length": certificate.get_course_length(),
            "course_end": certificate.get_course_end(),
            "reference_number": certificate.get_reference_number(),
            "created_at": datetime.now(timezone.utc).isoformat(),
            "source_system": "lambda_certificate",
        }
        logger.info(f"parsed data: {data}")
        upstream_key = f'{PREFIX_UPSTREAM_CERTIFICATE}/certificate_{CERTIFICATE_ID}.json'
        s3_client.put_object(
            Bucket=BUCKET_NAME,
            Key=upstream_key,
            Body=json.dumps(data).encode('utf-8'),
            ContentType="application/json"
        )
        logger.info("Uploading processed certificate to s3://%s/%s", BUCKET_NAME, upstream_key)

    except ClientError:
        logger.exception("S3 operation failed")
        raise

    except Exception:
        logger.exception("Unexpected failure")
        raise

    finally:
        logger.info("Stop lambda")
        logger.info("#" * 80)
