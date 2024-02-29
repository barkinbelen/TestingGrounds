#!/bin/bash

# Function to assume role and set up AWS CLI profile
setup_aws_profile() {
    # Assume role
    role_credentials=$(aws sts assume-role \
                        --role-arn "$1" \
                        --role-session-name "$2")

    # Extracting values from JSON response
    access_key=$(echo "$role_credentials" | jq -r '.Credentials.AccessKeyId')
    secret_key=$(echo "$role_credentials" | jq -r '.Credentials.SecretAccessKey')
    session_token=$(echo "$role_credentials" | jq -r '.Credentials.SessionToken')

    # Set up AWS CLI profile
    aws configure set aws_access_key_id "$access_key" --profile "$3"
    aws configure set aws_secret_access_key "$secret_key" --profile "$3"
    aws configure set aws_session_token "$session_token" --profile "$3"

    echo "AWS profile $3 configured successfully."
}

# Usage: ./script.sh <role-arn> <session-name> <profile-name>
setup_aws_profile "$1" "$2" "$3"
