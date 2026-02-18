aws lambda invoke \
  --function-name=$(terraform output -raw api_function_name) \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "course_id": "'$1'",
    "certificate_id": "'$2'",
    "bucket": "'$(terraform output -raw bucket_id)'",
    "prefix": "api-upstream-zone/"
    }' \
  response.json && cat response.json && rm response.json
