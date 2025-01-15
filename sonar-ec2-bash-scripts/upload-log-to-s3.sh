#!/bin/bash

# Define variables
LOG_FILE="/home/$(whoami)/ays-sonarqube-backup.sh.log"
BUCKET_NAME="<bucket-name>"
DATE=$(date +%Y%m%d%H%M)
LOG_FILE_NAME="sonarqube-backup-$DATE-log"

# Upload the log file to S3 with the new name
echo "**********************************************************"
echo "Uploading log file $LOG_FILE to S3 bucket $BUCKET_NAME as $LOG_FILE_NAME..."
aws s3 cp "$LOG_FILE" "s3://$BUCKET_NAME/$LOG_FILE_NAME" --quiet

if [ $? -eq 0 ]; then
    echo "Log file uploaded successfully as $LOG_FILE_NAME."
    echo "**********************************************************"
else
    echo "Failed to upload log file."
    echo "**********************************************************"

fi
