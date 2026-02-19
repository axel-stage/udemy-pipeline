#!/bin/bash
# invoke lambda function

source .env

aws lambda invoke \
  --function-name=${API_FUNCTION_NAME} \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "course_id": "'$1'",
    "certificate_id": "'$2'",
    "bucket_name": "'${BUCKET_NAME}'",
    "api_prefix": "'${API_PREFIX}'"
    }' \
  response.json && cat response.json && rm response.json
