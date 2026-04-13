#!/usr/bin/env bash

# Remove existing script if any
# rm sonarqube-setup.sh

# Make script executable and run with sudo
# nano sonarqube-setup.sh
# chmod +x sonarqube-setup.sh
# sudo ./sonarqube-setup.sh
# Note: Variables will be automatically retrieved from the GitHub Actions environment.

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

read -p "➡️ Enter SonarQube web port (default: 9009): " SQ_WEB_PORT
SQ_WEB_PORT="${SQ_WEB_PORT:-9009}"

read -p "➡️ Enter PgAdmin email (default: admin@admin.com): " PGADMIN_EMAIL
PGADMIN_EMAIL="${PGADMIN_EMAIL:-admin@admin.com}"

read -p "➡️ Enter PgAdmin password (default: admin): " PGADMIN_PASSWORD
PGADMIN_PASSWORD="${PGADMIN_PASSWORD:-admin}"


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
mkdir -p /aysapps/sonarqube/pgadmin_data


# === CONFIGURE DOCKER COMPOSE ===
# Copy docker-compose.yaml template and replace placeholders with user input
# Assuming the template exists in /aysapps/setup/sonarqube/docker-compose.yaml based on your structure
echo ""
echo "🐳 Configuring Docker Compose..."


# Check if template exists, otherwise we might need to create it or download it
if [[ -f ./docker-compose.yaml ]]; then
    cp ./docker-compose.yaml /aysapps/sonarqube/docker-compose.yaml
else
    echo "⚠️ Template not found! Please ensure that the ./docker-compose.yaml file exists."
    # Stopping the script here to prevent failure if the template is missing:"
    exit 1
fi


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