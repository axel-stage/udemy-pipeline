import boto3


AWS_RESOURCE = "s3"
s3 = boto3.client(AWS_RESOURCE)


def get_keys(bucket_name: str, prefix: str) -> list[str]:
    objects = s3.list_objects(Bucket=bucket_name, Prefix=prefix)
    keys = []
    for obj in objects["Contents"]:
        if obj["Size"] > 0:
            keys.append(obj["Key"])
    return keys


def get_object_from_bucket(bucket_name: str, key: str) -> str:
    object = s3.get_object(Bucket=bucket_name, Key=key)
    data = object["Body"].read()
    json_obj = data.decode("utf-8")
    return json_obj


def write_json_files(bucket_name: str, keys: list[str], file_name: str) -> None:
    counter = 0
    for key in keys:
        json_obj = get_object_from_bucket(bucket_name, key)
        with open(f"src/etl_pipeline/data/{file_name}-{counter}.json", "w") as file:
            file.write(json_obj)
        counter += 1


def extract_data(bucket_name: str, prefix: str, file_name: str) -> None:
    keys = get_keys(bucket_name, prefix)
    write_json_files(bucket_name, keys, file_name)
