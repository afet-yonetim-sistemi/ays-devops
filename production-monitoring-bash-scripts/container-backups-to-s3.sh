#!/bin/bash

# Variables
DIR_TO_BACKUP="<dir-path>"
BUCKET_NAME="<bucket-name>"
DATE=$(date +%Y_%m_%d_%H_%M)
ZIP_NAME="$(basename "$DIR_TO_BACKUP")-backup-$DATE.zip"
HOME_DIR="/home/$(whoami)"
ZIP_PATH="$HOME_DIR/$ZIP_NAME"
TEMP_BACKUP_DIR="$HOME_DIR/monitoring-backup-tmp-$DATE"
LOG_FILE="$HOME_DIR/container-backups.log"

# Start logging
echo "############### Backup Started at $(date) ###############" | tee -a "$LOG_FILE"

# Create temporary backup copy
echo "Copying files from $DIR_TO_BACKUP to $TEMP_BACKUP_DIR..." | tee -a "$LOG_FILE"
mkdir -p "$TEMP_BACKUP_DIR"
rsync -avh "$DIR_TO_BACKUP/" "$TEMP_BACKUP_DIR/" | tee -a "$LOG_FILE"

if [ $? -ne 0 ]; then
    echo "Rsync failed! Exiting." | tee -a "$LOG_FILE"
    rm -rf "$TEMP_BACKUP_DIR"
    exit 1
fi

# Zip the copied files
echo "Creating zip file: $ZIP_NAME..." | tee -a "$LOG_FILE"
zip -rq "$ZIP_PATH" "$TEMP_BACKUP_DIR"

if [ $? -eq 0 ]; then
    echo "Zip file created successfully: $ZIP_PATH" | tee -a "$LOG_FILE"
    FILE_SIZE=$(stat --printf="%s" "$ZIP_PATH")
    FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1048576" | bc)
    echo "Backup size is: $FILE_SIZE_MB MB" | tee -a "$LOG_FILE"
else
    echo "Failed to create zip file. Exiting." | tee -a "$LOG_FILE"
    rm -rf "$TEMP_BACKUP_DIR"
    exit 1
fi

# Cleanup temp copied files
echo "Cleaning up temporary backup directory..." | tee -a "$LOG_FILE"
rm -rf "$TEMP_BACKUP_DIR"

# Upload the zip file to S3
echo "Uploading $ZIP_NAME to S3 bucket $BUCKET_NAME..." | tee -a "$LOG_FILE"
aws s3 cp "$ZIP_PATH" "s3://$BUCKET_NAME/" --quiet

if [ $? -eq 0 ]; then
    echo "Upload completed. Deleting local zip file..." | tee -a "$LOG_FILE"
    rm -f "$ZIP_PATH"
else
    echo "Upload failed. Keeping the zip file for debugging." | tee -a "$LOG_FILE"
fi

# Final log entries
echo "############### End of Logging Session on $(date) ###############" | tee -a "$LOG_FILE"
echo "_____________________________________________________________" | tee -a "$LOG_FILE"

# Upload the log file to S3
aws s3 cp "$LOG_FILE" "s3://$BUCKET_NAME/logs/container-backups-$DATE.log"