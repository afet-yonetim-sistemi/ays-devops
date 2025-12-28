#!/bin/bash

# Set your AWS profile
AWS_PROFILE=ays

# Get the username associated with the AWS_PROFILE
USERNAME=$(aws iam get-user --profile $AWS_PROFILE --query 'User.UserName' --output text)

# Get the list of MFA devices for the user in JSON format
MFA_DEVICES_JSON=$(aws iam list-mfa-devices --user-name $USERNAME --profile $AWS_PROFILE --query 'MFADevices[*].SerialNumber' --output json)

# Check if MFA devices are retrieved
if [ -z "$MFA_DEVICES_JSON" ]; then
  echo "Unable to retrieve MFA devices."
  exit 1
fi

# Convert MFA devices JSON to an array
MFA_DEVICES_ARRAY=($(echo $MFA_DEVICES_JSON | jq -r '.[]'))

# Function to display MFA devices and get user's choice
select_mfa_device() {
  echo "Multiple MFA devices found. Please select one:"
  for i in "${!MFA_DEVICES_ARRAY[@]}"; do
    printf "%s) %s\n" "$(printf \\$(printf '%03o' $((97 + i))))" "${MFA_DEVICES_ARRAY[$i]}"
  done

  read -p "Enter the letter of the MFA device you want to use: " MFA_CHOICE
  CHOICE_INDEX=$(printf "%d" "'$MFA_CHOICE")
  CHOICE_INDEX=$((CHOICE_INDEX - 97))
  
  if ! [[ "$CHOICE_INDEX" =~ ^[0-9]+$ ]] || [ "$CHOICE_INDEX" -lt 0 ] || [ "$CHOICE_INDEX" -ge "${#MFA_DEVICES_ARRAY[@]}" ]; then
    echo "Invalid choice. Please run the script again and select a valid letter."
    exit 1
  fi

  MFA_SERIAL=${MFA_DEVICES_ARRAY[$CHOICE_INDEX]}
}

# Select the MFA device if more than one is available
if [ "${#MFA_DEVICES_ARRAY[@]}" -gt 1 ]; then
  select_mfa_device
else
  MFA_SERIAL=${MFA_DEVICES_ARRAY[0]}
fi

# Read the MFA code from the user
read -p "Enter MFA code: " MFA_CODE

# Assume the role using the MFA code to get temporary credentials
TEMP_CREDENTIALS=$(aws sts get-session-token --serial-number $MFA_SERIAL --token-code $MFA_CODE --profile $AWS_PROFILE)

# Export the temporary credentials as environment variables
export AWS_ACCESS_KEY_ID=$(echo $TEMP_CREDENTIALS | jq -r .Credentials.AccessKeyId)
export AWS_SECRET_ACCESS_KEY=$(echo $TEMP_CREDENTIALS | jq -r .Credentials.SecretAccessKey)
export AWS_SESSION_TOKEN=$(echo $TEMP_CREDENTIALS | jq -r .Credentials.SessionToken)

echo "Temporary credentials set successfully."
