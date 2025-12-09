# test ouput
terraform output

# invoke function
aws lambda invoke \
  --profile awsadmin24 \
  --region eu-central-1 \
  --function-name=$(terraform output -raw udemy_function_name) \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "url": "https://www.udemy.com/course/aws-data-engineer/",
    "bucket_name": "'$(terraform output -raw bucket_id)'",
    "upstream_prefix": "udemy-upstream-zone/"
    }' \
  response.json && cat response.json && rm response.json

# logs
aws logs tail /aws/lambda/$(terraform output -raw udemy_function_name) \
  --profile awsadmin24 \
  --region eu-central-1
