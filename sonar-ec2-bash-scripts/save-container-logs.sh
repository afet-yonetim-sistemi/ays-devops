#!/bin/bash

# Define container names, log directory, and bucket details
CONTAINERS=("sonarqube" "pgadmin" "postgresql")
LOG_DIR="/home/$(whoami)/container-logs"
BUCKET_NAME="ays-sonarqube-backup"
S3_PATH="container-logs"  # Path within the bucket for log storage
DATE=$(date +%Y%m%d%H%M)

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Start processing logs
echo "*******************************************************"
echo "Starting to save and upload logs for containers..."
echo "*******************************************************"

# Loop through containers and save their logs
for container in "${CONTAINERS[@]}"; do
    echo "-----------------------------------------------------"
    echo "Processing logs for container: $container"
    LOG_FILE="${LOG_DIR}/${container}-container-logs-${DATE}.log"

    # Use docker logs to save logs for each container
    docker logs "$container" > "$LOG_FILE" 2>&1

    # Print status
    if [ $? -eq 0 ]; then
        echo "Logs successfully saved for container: $container"
        echo "Log file saved at: $LOG_FILE"

        # Upload log file to S3
        echo "Uploading log file to S3..."
        aws s3 cp "$LOG_FILE" "s3://$BUCKET_NAME/$S3_PATH/${container}-container-logs-${DATE}.log" --quiet
        if [ $? -eq 0 ]; then
            echo "********************************************************"
            echo "Log file for $container uploaded successfully to S3."
            echo "Deleting local log file..."
            rm -f "$LOG_FILE"
            echo "Local log file deleted."
            echo "********************************************************"
        else
            echo "Failed to upload log file for $container to S3."
            echo "Retaining the log file locally for troubleshooting."
        fi
    else
        echo "Failed to save logs for container: $container"
    fi
    echo "-----------------------------------------------------"
done

# End of processing
echo "*******************************************************"
echo "Log processing completed for all containers."
echo "*******************************************************"
