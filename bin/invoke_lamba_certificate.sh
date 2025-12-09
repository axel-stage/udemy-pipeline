# test ouput
terraform output

# copy files
aws s3 cp /home/xl/projects/udemy_scraper/test s3://$(terraform output -raw bucket_id)/certificate-landing-zone/ --recursive \
  --profile awsadmin24 \
  --region eu-central-1

# invoke function
aws lambda invoke \
  --profile awsadmin24 \
  --region eu-central-1 \
  --function-name=$(terraform output -raw certificate_function_name) \
  --invocation-type RequestResponse \
  --cli-binary-format raw-in-base64-out \
  --payload '{
    "local_path": "/tmp/",
    "bucket_name": "'$(terraform output -raw bucket_id)'",
    "upstream_prefix": "certificate-upstream-zone/"
    }' \
  response.json && cat response.json && rm response.json

# logs
aws logs tail /aws/lambda/$(terraform output -raw certificate_function_name) \
  --profile awsadmin24 \
  --region eu-central-1
