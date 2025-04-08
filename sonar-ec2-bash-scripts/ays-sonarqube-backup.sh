#!/bin/bash

# Variables
DIR_TO_BACKUP="<backup-directory>"  
BUCKET_NAME="<bucket-name>"
DATE=$(date +%Y-%m-%d-%H-%M)
ZIP_NAME="$(basename "$DIR_TO_BACKUP")-backup-$DATE.zip"
HOME_DIR="/home/$(whoami)"
ZIP_PATH="$HOME_DIR/$ZIP_NAME"


# Date of the backup
echo "############### Backup Started at $(date) ###############"

# Create the zip file (suppress file-level details)
echo "Creating zip file: $ZIP_NAME..."
sudo zip -rq "$ZIP_PATH" "$DIR_TO_BACKUP"

if [ $? -eq 0 ]; then
    echo "Zip file created successfully: $ZIP_PATH"
    FILE_SIZE=$(stat --printf="%s" "$ZIP_PATH")
    FILE_SIZE_MB=$(echo "scale=2; $FILE_SIZE / 1048576" | bc)
    echo "Backup size is: $FILE_SIZE_MB MB"
else
    echo "Failed to create zip file. Exiting."
    exit 1
fi

# Upload the zip file to S3
echo "Uploading $ZIP_NAME to S3 bucket $BUCKET_NAME..."
aws s3 cp "$ZIP_PATH" "s3://$BUCKET_NAME/" --quiet

if [ $? -eq 0 ]; then
    echo "Upload completed. Deleting local zip file..."
    rm -f "$ZIP_PATH"
else
    echo "Upload failed. Keeping the zip file for debugging."
fi

echo "############### End of Logging Session on $(date) ###############"
echo "_____________________________________________________________"
