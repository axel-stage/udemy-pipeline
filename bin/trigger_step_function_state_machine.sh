#!/bin/bash

source .env

echo
echo "###################### Programm start ######################"
echo

# read map from file
if [[ -f bin/certificate_link_store ]]
then
    source bin/certificate_link_store
    echo "Load data"
else
    echo "No file bin/certificate_link_store"
fi

# print certificate_link_map
echo "Current certificate : link map"
for key in "${!certificate_link_map[@]}"
do
  echo "${key}: ${certificate_link_map[$key]}"
done

# clean
if [[ -f bin/batch_certificate_link.json ]]
then
    echo "Delete bin/batch_certificate_link.json"
    rm bin/batch_certificate_link.json
else
    echo "No file bin/batch_certificate_link.json"
fi

# build json
declare -A certificate_link_json
for key in ${!certificate_link_map[@]}
do
    if [[ ${certificate_link_map[$key]} != "none" ]]
    then
        certificate_link_json[${key}]=${certificate_link_map[$key]:29:-1}
    fi
done
iter_counter=0
cat <<EOF >> bin/batch_certificate_link.json
[
EOF
for key in ${!certificate_link_json[@]}
do
    let iter_counter++
    if [[ ${iter_counter} -lt ${#certificate_link_json[@]} ]]
    then
        cat <<EOF >> bin/batch_certificate_link.json
    {"certificate_id": "${key}", "course_slug": "${certificate_link_json[${key}]}"},
EOF
    else
            cat <<EOF >> bin/batch_certificate_link.json
    {"certificate_id": "${key}", "course_slug": "${certificate_link_json[${key}]}"}
EOF
    fi
done
cat <<EOF >> bin/batch_certificate_link.json
]
EOF

# upload certificates
for key in "${!certificate_link_map[@]}"
do
    if [[ ${certificate_link_map[${key}]} != "none" ]]
    then
        aws s3 cp "${LOCAL_CERTIFICATE_PATH}/${key}.jpg" s3://${BUCKET_NAME}/${PREFIX_LANDING_CERTIFICATE}/${key}.jpg
    fi
done

# upload to s3
aws s3 cp bin/batch_certificate_link.json s3://${BUCKET_NAME}/batch-trigger/batch_certificate_link.json

# aws s3 rm s3://${BUCKET_NAME}/batch-trigger/batch_certificate_link.json

echo
echo "################## Programm end ##################"
echo
