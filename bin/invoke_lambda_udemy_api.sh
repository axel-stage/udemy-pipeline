#!/bin/bash
# invoke lambda function

source .env

aws lambda invoke \
  --function-name=${API_FUNCTION_NAME} \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "COURSE_SLUG": "'$1'",
    "CERTIFICATE_ID": "'$2'",
    "BUCKET_NAME": "'${BUCKET_NAME}'",
    "PREFIX_UPSTREAM_API": "'${PREFIX_UPSTREAM_API}'"
    }' \
  response.json && cat response.json && rm response.json
