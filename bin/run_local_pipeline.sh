#!/bin/bash
# run local pipeline

source .env

# read map from file or create a new map
if [[ -f bin/certificate_link_store ]]
then
    source bin/certificate_link_store
else
    echo "Missing certificate link map"
fi


# upload certificates
for key in "${!certificate_link_map[@]}"
do
    if [[ ${certificate_link_map[${key}]} != "none" ]]
    then
        aws s3 cp "${LOCAL_CERTIFICATE_PATH}/${key}.jpg" s3://${BUCKET_NAME}/certificate-landing-zone/${key}.jpg
        sleep 1
    fi
done

# lambda certificate
####################
#aws s3 cp /home/xl/projects/udemy_scraper/test_data s3://${BUCKET_NAME}/certificate-landing-zone/ --recursive
aws s3 ls ${BUCKET_NAME}/certificate-landing-zone/
./bin/invoke_lambda_certificate.sh
aws s3 ls ${BUCKET_NAME}/${CERTIFICATE_PREFIX}/

# api
#####
for key in "${!certificate_link_map[@]}"
do
    if [[ ${certificate_link_map[${key}]} != "none" ]]
    then
        ./bin/invoke_lambda_udemy_api.sh ${certificate_link_map[${key}]:29:-1} ${key}
        sleep 1
    fi
done

aws s3 ls ${BUCKET_NAME}/${API_PREFIX}/

# pipeline
##########
./bin/invoke_lambda_pipeline.sh

# logs
######
aws logs tail /aws/lambda/${CERTIFICATE_FUNCTION_NAME}
aws logs tail /aws/lambda/${API_FUNCTION_NAME}
aws logs tail /aws/lambda/${PIPELINE_FUNCTION_NAME}
