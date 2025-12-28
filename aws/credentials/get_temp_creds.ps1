# Set your AWS profile
$AWS_PROFILE = "ays"

# Get the username associated with the AWS_PROFILE
$USERNAME = (aws iam get-user --profile $AWS_PROFILE --query 'User.UserName' --output text)

# Get the list of MFA devices for the user in JSON format
$MFA_DEVICES_JSON = (aws iam list-mfa-devices --user-name $USERNAME --profile $AWS_PROFILE --query 'MFADevices[*].SerialNumber' --output json)

# Check if MFA devices are retrieved
if (-not $MFA_DEVICES_JSON) {
    Write-Host "Unable to retrieve MFA devices."
    exit 1
}

# Convert MFA devices JSON to an array
$MFA_DEVICES_ARRAY = ($MFA_DEVICES_JSON | ConvertFrom-Json)

# Function to display MFA devices and get user's choice
function Select-MfaDevice {
    Write-Host "Multiple MFA devices found. Please select one:"
    for ($i = 0; $i -lt $MFA_DEVICES_ARRAY.Count; $i++) {
        $letter = [char]([int][char]'a' + $i)
        Write-Host "$letter) $($MFA_DEVICES_ARRAY[$i])"
    }

    $MFA_CHOICE = Read-Host "Enter the letter of the MFA device you want to use"
    $CHOICE_INDEX = [int][char]$MFA_CHOICE - [int][char]'a'

    if ($CHOICE_INDEX -lt 0 -or $CHOICE_INDEX -ge $MFA_DEVICES_ARRAY.Count) {
        Write-Host "Invalid choice. Please run the script again and select a valid letter."
        exit 1
    }

    $MFA_SERIAL = $MFA_DEVICES_ARRAY[$CHOICE_INDEX]
    return $MFA_SERIAL
}

# Select the MFA device if more than one is available
if ($MFA_DEVICES_ARRAY.Count -gt 1) {
    $MFA_SERIAL = Select-MfaDevice
} else {
    $MFA_SERIAL = $MFA_DEVICES_ARRAY[0]
}

# Read the MFA code from the user
$MFA_CODE = Read-Host "Enter MFA code"

# Assume the role using the MFA code to get temporary credentials
$TEMP_CREDENTIALS = (aws sts get-session-token --serial-number $MFA_SERIAL --token-code $MFA_CODE --profile $AWS_PROFILE | ConvertFrom-Json)

# Export the temporary credentials as environment variables
$env:AWS_ACCESS_KEY_ID = $TEMP_CREDENTIALS.Credentials.AccessKeyId
$env:AWS_SECRET_ACCESS_KEY = $TEMP_CREDENTIALS.Credentials.SecretAccessKey
$env:AWS_SESSION_TOKEN = $TEMP_CREDENTIALS.Credentials.SessionToken

Write-Host "Temporary credentials set successfully."
