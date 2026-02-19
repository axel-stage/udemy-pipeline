#!/bin/bash
# invoke lambda function

source .env

aws lambda invoke \
  --function-name=${CERTIFICATE_FUNCTION_NAME} \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "bucket_name": "'${BUCKET_NAME}'",
    "certificate_prefix": "'${CERTIFICATE_PREFIX}'"
    }' \
  response.json && cat response.json && rm response.json
