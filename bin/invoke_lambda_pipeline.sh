#!/bin/bash
# invoke lambda function

source .env

aws lambda invoke \
  --function-name=${PIPELINE_FUNCTION_NAME} \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "TABLE_NAME": "'${TABLE_NAME}'",
    "BUCKET_NAME": "'${BUCKET_NAME}'",
    "PREFIX_UPSTREAM_CERTIFICATE": "'${PREFIX_UPSTREAM_CERTIFICATE}'",
    "PREFIX_UPSTREAM_API": "'${PREFIX_UPSTREAM_API}'"
    }' \
  response.json && cat response.json && rm response.json
