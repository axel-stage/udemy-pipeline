# little helpers
terraform output

# S3
aws s3 ls
aws s3 ls udemy-xhmz/
aws s3 ls udemy-xhmz/api-upstream-zone/

# certificate
#############
# copy files
aws s3 cp /home/xl/projects/udemy_scraper/test s3://$(terraform output -raw bucket_id)/certificate-landing-zone/ --recursive
# logs
aws logs tail /aws/lambda/$(terraform output -raw certificate_function_name)

# udemy
#######

# logs
aws logs tail /aws/lambda/$(terraform output -raw udemy_function_name)
