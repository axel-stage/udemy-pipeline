import json
import time
import logging
import boto3
from botocore.exceptions import ClientError
from scraper import Scraper


logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    max_retries = 0
    logger.info(f"{"#" * 80}")
    logger.info("Start processing...")

    s3 = boto3.client('s3')

    url = event.get("url", "")
    bucket_name = event.get("bucket_name", "")
    upstream_prefix=event.get("upstream_prefix", "")

    logger.info(f"start parsing: {url}")
    udemy = Scraper(url)
    udemy.parse_webpage()
    data = {
        "url": url,
        "slug": udemy.get_slug(),
        "title": udemy.scrape_content("h1", {"class":"clp-lead__title"}),
        "headline": udemy.scrape_content("div", {"class": "clp-lead__headline"}),
        "instructors": udemy.scrape_content_list("a", {"class": "ud-instructor-links"}),
        "topics": udemy.scrape_content_list("a", {"class": "ud-heading-sm"}),
        "students_num": udemy.scrape_content("span", {"class": "ud-heading-sm"}),
        "rating": udemy.scrape_content("span", {"class": "ud-heading-xl"}),
        "language": udemy.scrape_content("div", {"data-purpose": "lead-course-locale"}),
        "created": str( time.strftime("%Y-%m-%d") ),
    }
    logger.info(f"parsed data: {data}")

    file_name = f'udemy_{data["slug"]}_{data["created"]}.json'
    key =  upstream_prefix + file_name
    try:
        s3.put_object(
            Body=json.dumps(data).encode('utf-8'),
            Bucket=bucket_name,
            Key=key
        )
        logger.info(f'file uploaded to: {bucket_name + "/" + key}')
    except ClientError as error:
      logger.error(error)

    logger.info("Stop processing...")
    logger.info(f"{"#" * 80}")
