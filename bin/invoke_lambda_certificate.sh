#!/bin/bash
# invoke lambda function

source .env

aws lambda invoke \
  --function-name=${CERTIFICATE_FUNCTION_NAME} \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "CERTIFICATE_ID": "'$1'",
    "BUCKET_NAME": "'${BUCKET_NAME}'",
    "PREFIX_LANDING_CERTIFICATE": "'${PREFIX_LANDING_CERTIFICATE}'",
    "PREFIX_UPSTREAM_CERTIFICATE": "'${PREFIX_UPSTREAM_CERTIFICATE}'"
    }' \
  response.json && cat response.json && rm response.json
