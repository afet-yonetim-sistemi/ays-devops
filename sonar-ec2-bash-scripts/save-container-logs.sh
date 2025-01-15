#!/bin/bash

# Define container names and log directory
CONTAINERS=("<container-1>" "<container-2>" "<container-3>")
LOG_DIR="<log-directory>"
BUCKET_NAME="<bucket-name>"
DATE=$(date +%Y%m%d%H%M)

# Ensure the log directory exists
mkdir -p "$LOG_DIR"

# Loop through containers and save their logs
for container in "${CONTAINERS[@]}"; do
    LOG_FILE="${LOG_DIR}/${container}-container-logs-${DATE}.log"

    # Use docker logs to save logs for each container
    docker logs "$container" > "$LOG_FILE"

    # Print status
    if [ $? -eq 0 ]; then
        echo "Logs saved for container: $container to $LOG_FILE"

        # Upload log file to S3
        aws s3 cp "$LOG_FILE" "s3://$BUCKET_NAME/container-logs/${container}-container-logs-${DATE}.log" --quiet
        if [ $? -eq 0 ]; then
            echo "Log file for $container uploaded successfully to S3."
        else
            echo "Failed to upload log file for $container to S3."
        fi
    else
        echo "Failed to save logs for container: $container"
    fi
done
