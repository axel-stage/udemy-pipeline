#!/bin/bash

CERTIFICATE_PATH="/mnt/c/Users/axels/Proton Drive/dataengineer24/My files/IT-Freelancer/udemy"

echo
echo "###################### Programm start ######################"
echo "Let us generate the certificate : link map for udemy courses"
echo

# read map from file or create a new map
if [[ -f bin/certificate_link_store ]]
then
    source bin/certificate_link_store
    cp bin/certificate_link_store bin/certificate_link_store.backup
else
    declare -A certificate_link_map
fi

# load map from file
stored_certificates=()
readarray -t files < <(ls "${CERTIFICATE_PATH}")
for file in ${files[@]}
do
    if [[ ${file} == *".jpg" ]]
    then
        stored_certificates+=(${file:0:39})
    fi
done

# add stored certificates to as keys in map if not exists
for cert_id in ${stored_certificates[@]}
do
    match=false
    for key in ${!certificate_link_map[@]}
    do
        if [[ ${cert_id} == ${key} ]]
        then
            match=true
        fi
    done
    if [[ ${match} == false ]]
    then
        certificate_link_map[${cert_id}]=none
    fi
done

# print certificate_link_map
echo "Current certificate : link map"
for key in "${!certificate_link_map[@]}"
do
  echo "${key}: ${certificate_link_map[$key]}"
done

# human loop to add links
for key in "${!certificate_link_map[@]}"
do
    if [[ ${certificate_link_map[${key}]} == "none" ]]
    then
        echo
        echo "Open the website in the browser."
        echo https://www.ude.my/${key}
        read -r -p "Copy and enter the course link: " link
        certificate_link_map[${key}]=${link}
        read -r -p "Continue? (Y/N): " answer
        case ${answer} in
            [Yy]* ) continue;;
            [Nn]* ) break;;
            * ) echo "Please answer Y or N.";;
        esac
    fi
done

# save current map to file
declare -p certificate_link_map > bin/certificate_link_store

# remove backup
if [[ -f bin/certificate_link_store.backup ]]
then
    rm bin/certificate_link_store.backup
fi

# count missing mappings
counter_total=0
counter_mapping=0
for key in "${!certificate_link_map[@]}"
do
    let counter_total++
    if [[ ${certificate_link_map[$key]} != "none" ]]
    then
        let counter_mapping++
    fi
done
let missing_mapping=counter_total-counter_mapping
echo
echo "######## Stats ########"
echo "total certificates: ${counter_total}"
echo "total mappings    : ${counter_mapping}"
echo "missing mappings  : ${missing_mapping}"
echo
echo "################## Programm end ##################"
echo
