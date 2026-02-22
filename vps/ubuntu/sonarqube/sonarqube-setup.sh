#!/usr/bin/env bash

# Remove existing script if any
# rm sonarqube-setup.sh

# Make script executable and run with sudo
# nano sonarqube-setup.sh
# chmod +x sonarqube-setup.sh
# sudo ./sonarqube-setup.sh

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"

# === CHECK IF SONARQUBE ALREADY INSTALLED ===
# Skip installation if the directory already exists
if [[ -d /aysapps/sonarqube ]]; then
  echo ""
  echo "✅ SonarQube already installed (/aysapps/sonarqube exists). Skipping installation."
  exit 0
fi


# === DATABASE CONFIGURATION INPUT ===
# Ask for PostgreSQL configuration parameters for SonarQube
echo ""
echo "📊 SonarQube Database Configuration"
read -p "➡️ Enter database name (default: sonarqube): " SQ_DB_NAME
SQ_DB_NAME="${SQ_DB_NAME:-sonarqube}"

read -p "➡️ Enter database user (default: sonar): " SQ_DB_USER
SQ_DB_USER="${SQ_DB_USER:-sonar}"

read -p "➡️ Enter database password (default: sonarpass): " SQ_DB_PASSWORD
SQ_DB_PASSWORD="${SQ_DB_PASSWORD:-sonarpass}"

read -p "➡️ Enter SonarQube web port (default: 9000): " SQ_WEB_PORT
SQ_WEB_PORT="${SQ_WEB_PORT:-9009}"


# === SETUP DIRECTORY STRUCTURE ===
# Create necessary directories
echo ""
echo "📦 Setting up directory structure..."
mkdir -p /aysapps/sonarqube
mkdir -p /aysapps/sonarqube/sonarqube_conf
mkdir -p /aysapps/sonarqube/sonarqube_data
mkdir -p /aysapps/sonarqube/sonarqube_extensions
mkdir -p /aysapps/sonarqube/sonarqube_logs
mkdir -p /aysapps/sonarqube/sonarqube_temp
mkdir -p /aysapps/sonarqube/postgresql_data


# === CONFIGURE DOCKER COMPOSE ===
# Copy docker-compose.yml template and replace placeholders with user input
# Assuming the template exists in /aysapps/setup/sonarqube/docker-compose.yml based on your structure
echo ""
echo "🐳 Configuring Docker Compose..."


# Check if template exists, otherwise we might need to create it or download it
if [[ -f /aysapps/setup/sonarqube/docker-compose.yml ]]; then
    cp --update=none /aysapps/sonarqube/docker-compose.yml /aysapps/setup/sonarqube/docker-compose.yml
else
    echo "⚠️ Template not found! Please ensure that the /aysapps/sonarqube/docker-compose.yaml file exists."
    # Stopping the script here to prevent failure if the template is missing:"
    exit 1
fi


# Replace all placeholders with actual values
sed -i "s#{{SQ_DB_NAME}}#${SQ_DB_NAME}#g" /aysapps/sonarqube/docker-compose.yml
sed -i "s#{{SQ_DB_USER}}#${SQ_DB_USER}#g" /aysapps/sonarqube/docker-compose.yml
sed -i "s#{{SQ_DB_PASSWORD}}#${SQ_DB_PASSWORD}#g" /aysapps/sonarqube/docker-compose.yml
sed -i "s#{{SQ_WEB_PORT}}#${SQ_WEB_PORT}#g" /aysapps/sonarqube/docker-compose.yml


# === PERMISSIONS ===
# Ensure correct permissions for mapped volumes (SonarQube runs as non-root user 1000 usually)
echo ""
echo "🔐 Setting permissions..."
chown -R 1000:1000 /aysapps/sonarqube/sonarqube_*
chown -R 999:999 /aysapps/sonarqube/postgresql_data


# === START DOCKER CONTAINERS ===
# Build and start the containers in detached mode
echo ""
echo "🚀 Starting SonarQube containers..."
cd /aysapps/sonarqube
sudo docker compose up -d

echo ""
echo "✅ SonarQube setup completed successfully."
echo "🌍 Access URL: http://localhost:${SQ_WEB_PORT} (or configured domain)"