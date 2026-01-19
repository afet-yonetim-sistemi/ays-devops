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

cd /aysapps


# === AYS FE LANDING SETUP ===
# Clone repository, configure environment variables and start containers
if [[ -d /aysapps/ays-fe-landing ]]; then
  echo ""
  echo "✅ AYS FE Landing project already installed (/aysapps/ays-fe-landing exists). Skipping installation."
else
  # === LANDING APPLICATION CONFIGURATION ===
  # Ask for Landing application configuration parameters
  echo ""
  echo "🌐 Landing Application Configuration"
  read -p "➡️ Enter Landing API URL (default: http://localhost:9790): " API_URL
  API_URL="${API_URL:-http://localhost:9790}"

  read -p "➡️ Enter Landing environment (default: test): " ENVIRONMENT
  ENVIRONMENT="${ENVIRONMENT:-test}"

  echo ""
  echo "📦 Cloning AYS FE Landing repository..."
  gh repo clone afet-yonetim-sistemi/ays-fe-landing

  cd /aysapps/ays-fe-landing

  echo "🔧 Configuring Landing environment variables..."
  cp /aysapps/setup/project/front-end/landing/.env /aysapps/ays-fe-landing/.env

  # Replace placeholders with actual values
  sed -i "s|{{API_URL}}|${API_URL}|g" /aysapps/ays-fe-landing/.env
  sed -i "s|{{ENVIRONMENT}}|${ENVIRONMENT}|g" /aysapps/ays-fe-landing/.env

  echo "🚀 Starting Landing Docker containers..."
  sudo docker compose up -d --build

  echo "✅ AYS FE Landing setup completed!"
fi


# === AYS FE INSTITUTION SETUP ===
# Clone repository, configure environment variables and start containers
if [[ -d /aysapps/ays-fe-institution ]]; then
  echo ""
  echo "✅ AYS FE Institution project already installed (/aysapps/ays-fe-institution exists). Skipping installation."
else

  # === INSTITUTION APPLICATION CONFIGURATION ===
  # Ask for Institution application configuration parameters
  echo ""
  echo "🏢 Institution Application Configuration"
  read -p "➡️ Enter Institution API URL (default: http://localhost:9790): " API_URL
  API_URL="${API_URL:-http://localhost:9790}"

  echo ""
  echo "📦 Cloning AYS FE Institution repository..."
  gh repo clone afet-yonetim-sistemi/ays-fe-institution

  cd /aysapps/ays-fe-institution

  echo "🔧 Configuring Institution environment variables..."
  cp /aysapps/setup/project/front-end/institution/.env /aysapps/ays-fe-institution/.env

  # Replace placeholders with actual values
  sed -i "s|{{API_URL}}|${API_URL}|g" /aysapps/ays-fe-institution/.env

  echo "🚀 Starting Institution Docker containers..."
  sudo docker compose up -d --build

  echo "✅ AYS FE Institution setup completed!"
fi


# === AYS FE LANDING PRODUCTION SETUP ===
# Copy from landing instance and apply production-specific configurations (skipped as per request)
if [[ -d /aysapps/ays-fe-landing-production ]]; then
  echo ""
  echo "✅ AYS FE Landing Production project already installed (/aysapps/ays-fe-landing-production exists). Skipping installation."
else
  echo ""
  echo "📦 Setting up AYS FE Landing Production..."
  cp -r /aysapps/ays-fe-landing /aysapps/ays-fe-landing-production

  cd /aysapps/ays-fe-landing-production

  cp /aysapps/setup/project/front-end/landing-production/Dockerfile /aysapps/ays-fe-landing-production/Dockerfile
  cp /aysapps/setup/project/front-end/landing-production/docker-compose.yml /aysapps/ays-fe-landing-production/docker-compose.yml

  echo "🚀 Starting Landing Production Docker containers..."
  sudo docker compose up -d --build

  echo "✅ AYS FE Landing Production setup completed!"
fi


# === AYS FE LANDING NEW SETUP ===
# Copy from landing instance, configure environment variables and adjust ports
if [[ -d /aysapps/ays-fe-landing-new ]]; then
  echo ""
  echo "✅ AYS FE Landing New project already installed (/aysapps/ays-fe-landing-new exists). Skipping installation."
else

  # === LANDING NEW APPLICATION CONFIGURATION ===
  # Ask for Landing New application configuration parameters
  echo ""
  echo "🆕 Landing New Application Configuration"
  read -p "➡️ Enter Landing New API URL (default: http://localhost:9790): " API_URL
  API_URL="${API_URL:-http://localhost:9790}"

  read -p "➡️ Enter Landing New environment (default: test): " ENVIRONMENT
  ENVIRONMENT="${ENVIRONMENT:-test}"

  echo ""
  echo "📦 Setting up AYS FE Landing New..."
  cp -r /aysapps/ays-fe-landing /aysapps/ays-fe-landing-new

  cd /aysapps/ays-fe-landing-new

  echo "🔧 Configuring Landing New environment variables..."
  cp /aysapps/setup/project/front-end/landing-new/.env /aysapps/ays-fe-landing-new/.env

  # Replace placeholders with actual values
  sed -i "s|{{API_URL}}|${API_URL}|g" /aysapps/ays-fe-landing-new/.env
  sed -i "s|{{ENVIRONMENT}}|${ENVIRONMENT}|g" /aysapps/ays-fe-landing-new/.env

  # Update port from 19790 to 19792 in configuration files
  sed -i 's/19790/19792/g' /aysapps/ays-fe-landing-new/package.json
  sed -i 's/19790/19792/g' /aysapps/ays-fe-landing-new/Dockerfile
  sed -i 's/19790/19792/g' /aysapps/ays-fe-landing-new/docker-compose.yml

  echo "🚀 Starting Landing New Docker containers..."
  sudo docker compose up -d --build

  echo "✅ AYS FE Landing New setup completed!"
fi
