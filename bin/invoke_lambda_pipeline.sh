#!/bin/bash
# invoke lambda function

source .env

aws lambda invoke \
  --function-name=${PIPELINE_FUNCTION_NAME} \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "table_name": "'${TABLE_NAME}'",
    "bucket_name": "'${BUCKET_NAME}'",
    "prefix_certificate": "'${CERTIFICATE_PREFIX}'",
    "prefix_api": "'${API_PREFIX}'"
    }' \
  response.json && cat response.json && rm response.json
