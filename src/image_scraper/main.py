import json
import time
import logging
import boto3
from botocore.exceptions import ClientError
from image_scraper import UdemyCertificateScraper


logger = logging.getLogger(__name__)
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(name)s | %(message)s",
)


def list_jpg_keys_in_bucket(bucket: str) -> list[str]:
    """Get a list of keys which end with 'jpg' in an S3 bucket."""
    s3_resource = boto3.resource('s3')
    s3_bucket = s3_resource.Bucket(bucket)
    keys = []
    for obj in s3_bucket.objects.all():
        if obj.key.endswith(".jpg"):
            keys.append(obj.key)
    return keys

def lambda_handler(event, context):
    logger.info(f"{"#" * 80}")
    logger.info("Start processing...")

    s3_client = boto3.client('s3')
    bucket_name: str = event.get("bucket_name", "")
    certificate_prefix: str = event.get("certificate_prefix", "")
    #local_path: str = event.get("local_path", "")

    jpg_keys = list_jpg_keys_in_bucket(bucket_name)
    logger.info(f"jpg keys: {jpg_keys}")
    for jpg_key in jpg_keys:
        logger.info(f"start download {jpg_key}")
        file_name = jpg_key.split('/')[1]
        file_path = f"/tmp/{file_name}"
        try:
            s3_client.download_file(
                Bucket=bucket_name,
                Key=jpg_key,
                Filename=file_path
            )
        except ClientError as error:
            logging.error(error)

        logger.info(f"start parsing: {file_path}")
        certificate = UdemyCertificateScraper(file_path)
        certificate.parse_image_text()
        data = {
            "owner": certificate.get_owner(),
            "certificate_id": certificate.get_certificate_id(),
            "instructors": certificate.get_instructors(),
            "title": certificate.get_title(),
            "course_length": certificate.get_course_length(),
            "course_end": certificate.get_course_end(),
            "reference_number": certificate.get_reference_number(),
            "created": str( time.strftime("%Y-%m-%d") ),
        }
        logger.info(f"parsed data: {data}")

        key = f'{certificate_prefix}certificate_{data["certificate_id"]}_{data["created"]}.json'
        try:
            s3_client.put_object(
                Body=json.dumps(data).encode('utf-8'),
                Bucket=bucket_name,
                Key=key
            )
            logger.info(f'file uploaded to: {bucket_name + "/" + key}')
        except ClientError as error:
            logging.error(error)
    logger.info("Stop processing...")
    logger.info(f"{"#" * 80}")
