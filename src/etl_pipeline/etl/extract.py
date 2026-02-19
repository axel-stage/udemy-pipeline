import boto3
from pathlib import Path

AWS_RESOURCE = "s3"


s3 = boto3.client(AWS_RESOURCE)


def get_keys(bucket_name: str, prefix: str) -> list[str]:
    """
    Retrieve all object keys from an S3 bucket under a given prefix.

    Uses pagination to safely handle buckets with more than 1000 objects.

    Args:
        bucket_name: Name of the S3 bucket.
        prefix: Key prefix to filter objects.

    Returns:
        List of S3 object keys.
    """
    paginator = s3.get_paginator("list_objects_v2")
    keys: list[str] = []

    for page in paginator.paginate(Bucket=bucket_name, Prefix=prefix):
        for obj in page.get("Contents", []):
            if obj["Size"] > 0:
                keys.append(obj["Key"])

    return keys


def get_object_from_bucket(bucket_name: str, key: str) -> str:
    """
    Download an S3 object and return its contents as UTF-8 text.

    Args:
        bucket_name: Name of the S3 bucket.
        key: Object key.

    Returns:
        Object contents as string.
    """
    response = s3.get_object(Bucket=bucket_name, Key=key)
    return response["Body"].read().decode("utf-8")


def write_json_files(bucket_name: str, keys: list[str], storage_path: str, file_name: str) -> None:
    """
    Write S3 JSON objects to local files.

    Files are written sequentially using the pattern:
    {file_name}-{counter}.json

    Args:
        bucket_name: Source S3 bucket.
        keys: List of object keys to download.
        file_name: Base filename for local JSON files.

    Returns:
        None
    """
    for counter, key in enumerate(keys):
        json_obj = get_object_from_bucket(bucket_name, key)
        file_path = f"{storage_path}/{file_name}-{counter}.json"
        with open(file_path, "w", encoding="utf-8") as file:
            file.write(json_obj)


def extract_data(bucket_name: str, prefix: str, storage_path: str, file_name: str) -> None:
    """
    Extract JSON files from S3 and land them locally for Bronze ingestion.

    This represents the extraction phase of the medallion pipeline.

    Args:
        bucket_name: Source S3 bucket.
        prefix: Object prefix to filter files.
        file_name: Base name for local JSON outputs.

    Returns:
        None
    """
    keys = get_keys(bucket_name, prefix)

    if not keys:
        raise Exception(
            f"No valid S3 objects found in bucket '{bucket_name}' with prefix '{prefix}'"
        )

    write_json_files(bucket_name, keys, storage_path, file_name)
