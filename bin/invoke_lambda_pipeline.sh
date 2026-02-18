# invoke function
aws lambda invoke \
  --function-name=udemy-pipeline \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "table_name": "UdemyCourse",
    "bucket_name": "udemy-kebw",
    "prefix_certificate": "certificate-upstream-zone/",
    "prefix_api": "api-upstream-zone/",
    "storage_path": "/tmp"
    }' \
  response.json && cat response.json && rm response.json
