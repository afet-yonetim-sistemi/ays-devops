#!/bin/bash

# Variables
DIR_TO_BACKUP="/aysapps/monitoring/"
BUCKET_NAME="ays-production-monitoring-ec2-container-backups"
DATE=$(date +%Y_%m_%d_%H_%M)
ZIP_NAME="$(basename "$DIR_TO_BACKUP")-backup-$DATE.zip"
HOME_DIR="/home/$(whoami)"
ZIP_PATH="$HOME_DIR/$ZIP_NAME"
LOG_FILE="$HOME_DIR/container-backups.log"

# Date of the backup
echo "############### Backup Started at $(date) ###############" | tee -a $LOG_FILE

# Create the zip file (suppress file-level details)
echo "Creating zip file: $ZIP_NAME..." | tee -a $LOG_FILE
sudo zip -rq "$ZIP_PATH" "$DIR_TO_BACKUP"

if [ $? -eq 0 ]; then
    echo "Zip file created successfully: $ZIP_PATH" | tee -a $LOG_FILE
    FILE_SIZE=$(stat --printf="%s" "$ZIP_PATH")
    FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1048576" | bc)
    echo "Backup size is: $FILE_SIZE_MB MB" | tee -a $LOG_FILE
else
    echo "Failed to create zip file. Exiting." | tee -a $LOG_FILE
    exit 1
fi

# Upload the zip file to S3
echo "Uploading $ZIP_NAME to S3 bucket $BUCKET_NAME..." | tee -a $LOG_FILE
aws s3 cp "$ZIP_PATH" "s3://$BUCKET_NAME/" --quiet | tee -a $LOG_FILE

if [ $? -eq 0 ]; then
    echo "Upload completed. Deleting local zip file..." | tee -a $LOG_FILE
    rm -f "$ZIP_PATH"
else
    echo "Upload failed. Keeping the zip file for debugging." | tee -a $LOG_FILE
fi

echo "############### End of Logging Session on $(date) ###############" | tee -a $LOG_FILE
echo "_____________________________________________________________" | tee -a $LOG_FILE

# Upload the log file to S3
aws s3 cp "$LOG_FILE" "s3://$BUCKET_NAME/logs/container-backups-$DATE.log"