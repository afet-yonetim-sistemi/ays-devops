#!/usr/bin/env bash

# Remove existing script if any
# rm docker-setup.sh

# Make script executable and run with sudo
# nano docker-setup.sh
# chmod +x docker-setup.sh
# sudo ./docker-setup.sh

# https://www.interserver.net/tips/kb/how-to-install-docker-on-ubuntu-24-04-lts/

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"

if command -v docker >/dev/null 2>&1; then
  echo ""
  echo "✅ Docker already installed: $(docker -v 2>&1)"
  exit 0
fi


# === SYSTEM UPDATE & DEPENDENCIES ===
# Update package index and upgrade installed packages
echo "🔄 Updating system packages..."
sudo apt update && sudo apt upgrade -y

# Installs required dependencies for using HTTPS repositories and downloading keys/packages.
echo "📦 Installing dependencies..."
sudo apt install apt-transport-https ca-certificates curl software-properties-common -y


# === DOCKER REPOSITORY SETUP ===
# Downloads Docker’s official GPG key and saves it as an APT keyring file for package signature verification.
echo "🔑 Adding Docker GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adds Docker’s official APT repository (matching your architecture + Ubuntu codename) and ties it to the saved keyring.
echo "🏛️ Adding Docker repository..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Updates the package index again to include packages from the newly added Docker repository.
sudo apt update


# === INSTALLATION & CONFIGURATION ===
# Installs Docker Engine, CLI, container runtime, and Buildx/Compose plugins.
echo "🐳 Installing Docker Engine..."
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# Enable and start Docker service
echo "🚀 Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Prints the installed Docker version to confirm installation.
docker --version
