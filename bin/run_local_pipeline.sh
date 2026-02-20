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
        aws s3 cp "${LOCAL_CERTIFICATE_PATH}/${key}.jpg" s3://${BUCKET_NAME}/${PREFIX_LANDING_CERTIFICATE}/${key}.jpg
    fi
done

# invoke lambda certificate
aws s3 ls ${BUCKET_NAME}/${PREFIX_LANDING_CERTIFICATE}/

for key in "${!certificate_link_map[@]}"
do
    if [[ ${certificate_link_map[${key}]} != "none" ]]
    then
        ./bin/invoke_lambda_certificate.sh ${key}
    fi
done

aws s3 ls ${BUCKET_NAME}/${PREFIX_UPSTREAM_CERTIFICATE}/

# invoke lambda api
for key in "${!certificate_link_map[@]}"
do
    if [[ ${certificate_link_map[${key}]} != "none" ]]
    then
        ./bin/invoke_lambda_udemy_api.sh ${certificate_link_map[${key}]:29:-1} ${key}
    fi
done

aws s3 ls ${BUCKET_NAME}/${PREFIX_UPSTREAM_API}/

# invoke lambda pipeline
./bin/invoke_lambda_pipeline.sh


# dynamodb
aws dynamodb query \
  --table-name ${TABLE_NAME} \
  --key-condition-expression "PartitionKey = :pk and begins_with(SortKey, :sk)" \
  --expression-attribute-values '{":pk": {"S":"owner#Axel Stage"}, ":sk": {"S":"year#None"}}' \
  --no-scan-index-forward \
  --return-consumed-capacity TOTAL


echo ${CERTIFICATE_FUNCTION_NAME}
# logs
aws logs tail /aws/lambda/${CERTIFICATE_FUNCTION_NAME}
aws logs tail /aws/lambda/${API_FUNCTION_NAME}
aws logs tail /aws/lambda/${PIPELINE_FUNCTION_NAME}
