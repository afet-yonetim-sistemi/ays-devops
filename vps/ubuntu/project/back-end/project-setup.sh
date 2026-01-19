#!/usr/bin/env bash

# Remove existing script if any
# rm project-setup.sh

# Make script executable and run with sudo
# nano project-setup.sh
# chmod +x project-setup.sh
# sudo ./project-setup.sh

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"


# === CHECK IF PROJECT ALREADY INSTALLED ===
# Skip installation if the project directory already exists
if [[ -d /aysapps/ays-be ]]; then
  echo ""
  echo "✅ AYS BE project already installed (/aysapps/ays-be exists). Skipping installation."
  exit 0
fi


# === DATABASE CONFIGURATION INPUT ===
# Ask for database configuration parameters
echo ""
echo "📊 Database Configuration"
read -p "➡️ Enter database name (default: ays): " DB_NAME
DB_NAME="${DB_NAME:-ays}"

read -p "➡️ Enter database user (default: ays): " DB_USER
DB_USER="${DB_USER:-ays}"

read -p "➡️ Enter database password (default: ayspass): " DB_PASSWORD
DB_PASSWORD="${DB_PASSWORD:-ayspass}"

read -p "➡️ Enter database root password (default: ayspass): " DB_ROOT_PASSWORD
DB_ROOT_PASSWORD="${DB_ROOT_PASSWORD:-ayspass}"

read -p "➡️ Enter database port (default: 63306): " DB_PORT
DB_PORT="${DB_PORT:-63306}"


# === APPLICATION CONFIGURATION INPUT ===
# Ask for application configuration parameters
echo ""
echo "🚀 Application Configuration"
read -p "➡️ Enter CORS allowed origins (default: http://localhost:19790,http://localhost:29790): " CORS_ALLOWED_ORIGINS
CORS_ALLOWED_ORIGINS="${CORS_ALLOWED_ORIGINS:-http://localhost:19790,http://localhost:29790}"


# === SMTP CONFIGURATION INPUT ===
# Ask for SMTP configuration parameters
echo ""
echo "📧 SMTP Configuration"
read -p "➡️ Enter SMTP username (default: smtp@afetyonetimsistemi.test): " SMTP_USERNAME
SMTP_USERNAME="${SMTP_USERNAME:-smtp@afetyonetimsistemi.test}"

read -p "➡️ Enter SMTP password (default: ayssmtppass): " SMTP_PASSWORD
SMTP_PASSWORD="${SMTP_PASSWORD:-ayssmtppass}"


# === CLONE AND SETUP PROJECT ===
# Clone the repository and run initial setup
echo ""
echo "📦 Cloning AYS BE repository..."
cd /aysapps

gh repo clone afet-yonetim-sistemi/ays-be

cd /aysapps/ays-be

echo ""
echo "🔧 Running project setup..."
bash ./setup/setup.sh


# === COPY AND CONFIGURE DOCKER COMPOSE ===
# Copy docker-compose.yml template and replace placeholders with user input
echo ""
echo "🐳 Configuring Docker Compose..."
cp /aysapps/setup/project/back-end/docker-compose.yml /aysapps/ays-be/docker-compose.yml

# Replace all placeholders with actual values
sed -i "s|{{DB_NAME}}|${DB_NAME}|g" /aysapps/ays-be/docker-compose.yml
sed -i "s|{{DB_USER}}|${DB_USER}|g" /aysapps/ays-be/docker-compose.yml
sed -i "s|{{DB_PASSWORD}}|${DB_PASSWORD}|g" /aysapps/ays-be/docker-compose.yml
sed -i "s|{{DB_ROOT_PASSWORD}}|${DB_ROOT_PASSWORD}|g" /aysapps/ays-be/docker-compose.yml
sed -i "s|{{DB_PORT}}|${DB_PORT}|g" /aysapps/ays-be/docker-compose.yml
sed -i "s|{{CORS_ALLOWED_ORIGINS}}|${CORS_ALLOWED_ORIGINS}|g" /aysapps/ays-be/docker-compose.yml
sed -i "s|{{SMTP_USERNAME}}|${SMTP_USERNAME}|g" /aysapps/ays-be/docker-compose.yml
sed -i "s|{{SMTP_PASSWORD}}|${SMTP_PASSWORD}|g" /aysapps/ays-be/docker-compose.yml


# === START DOCKER CONTAINERS ===
# Build and start the containers in detached mode
echo ""
echo "🚀 Starting Docker containers..."
sudo docker compose up -d --build

# 🚨 IMPORTANT!!! Disable cloudflare challenge page for API subdomain to work properly
