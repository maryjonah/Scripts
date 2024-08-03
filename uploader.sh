#!/bin/bash

# Paths for installation and user config
AWS_INSTALL="/usr/local/bin/aws"
AWS_CRED_FILE="${HOME}/.aws/credentials"

# Colors
RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'

# Text styling
BOLD='\e[1m'
UNDERLINE='\e[4m'

# Style datetime
DATE_TIME="${GREEN}${BOLD}${UNDERLINE}[$(date +%X)]${RESET}"

# Install awscli for Ubuntu
install_aws_cli() {
  echo -e "${DATE_TIME} Installing awscli"
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  unzip awscliv2.zip
  sudo ./aws/install
  rm -rf awscliv2.zip aws
}

# Store access and secret key configuration details
config_store() {
  echo -e "${DATE_TIME} Configuring user credentials"
  aws configure
}

# List bucket names in user's current region
# An internal function that extracts only the name of the bucket from the format below:
# 2024-08-03 14:44:57 learn-to-cloud-bucket
_format_s3_list() {
  s3_list=$(aws s3 ls)
  bucket_names=()
  while IFS= read -r line;
  do
    last_word=$(echo "$line" | cut -d ' ' -f3)
    bucket_names+=("$last_word")
  done <<< "$s3_list"
}
# Another internal function that prints the index and name of bucket
_print_bucket_names() {
  bucket_index=()
  for idx in "${!bucket_names[@]}";
  do
    bucket_index+=("$idx")
    name="${bucket_names[$idx]}"
    echo "$((idx+1)) $name"
  done
}
# Calls the 2 internal commands above to format and return the list of all S3 buckets
list_existing_s3_bucket() {
  echo -e "${DATE_TIME} Listing all buckets in the current region"
  _format_s3_list
  _print_bucket_names
}

# Inform user to select which bucket to use for the upload
select_s3_bucket() {
  echo -e "${DATE_TIME} Get S3 Bucket to upload to"
  read -p "Provide S3 bucket number you wish to upload to: " s3_bucket_idx

  selected_bucket=${bucket_names[$((s3_bucket_idx-1))]}

  if [ -z "$selected_bucket" ];
  then
    echo -e "${BOLD}${RED}Invalid bucket number"

    select_s3_bucket
  fi
}

# Inform user to provide path to file
get_file_path() {
  echo -e "${DATE_TIME} Provide file path to upload]"
  read -p "Full path to file to upload: " file_path
}

# Upload file to selected S3 bucket
upload_file() {
  echo -e "${DATE_TIME} Uploading file to '${selected_bucket}'"
  aws s3 cp "$file_path" "s3://${selected_bucket}"
  echo -e ""
}


printf "usage: ./uploader.sh [path_to_file]\n\n"

[[ -L ${AWS_INSTALL} ]] || install_aws_cli

[[ -f ${AWS_CRED_FILE} ]] || config_store

list_existing_s3_bucket

select_s3_bucket

get_file_path

upload_file
