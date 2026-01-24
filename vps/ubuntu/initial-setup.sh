#!/usr/bin/env bash

# Remove existing script if any
# rm initial-setup.sh

# Make script executable and run with sudo
# nano initial-setup.sh
# chmod +x initial-setup.sh
# bash ./initial-setup.sh

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"

# === SERVER IP / HOST INPUT ===
# Ask for server IP/host until a non-empty value is provided
while true; do
  echo ""
  read -p "➡️ Enter server IP (or host): " SERVER_IP
  [[ -n "$SERVER_IP" ]] && break
  echo "Please enter a server IP/host."
done


# === SSH CONNECTION SETTINGS ===
# Read SSH username and port, apply defaults if empty
read -p "➡️ Enter SSH username (default: ubuntu): " SSH_USER
SSH_USER="${SSH_USER:-ubuntu}"

read -p "➡️ Enter SSH port (default: 22): " SSH_PORT
SSH_PORT="${SSH_PORT:-22}"


# === COPY LOCAL SETUP TO REMOTE SERVER ===
# Copy the current directory to the remote user's home directory
echo ""
echo "📦 Copying current directory -> ${SSH_USER}@${SERVER_IP}:~/setup"
scp -P "$SSH_PORT" -r . "${SSH_USER}@${SERVER_IP}:~/setup" || exit 1


# === MOVE SETUP INTO SYSTEM DIRECTORY WITH SUDO ===
# Connect via SSH and move the setup directory to /aysapps with root permissions
echo ""
echo "🧱 Moving to /aysapps/setup with sudo..."
ssh -p "$SSH_PORT" -t "${SSH_USER}@${SERVER_IP}" "sudo bash - <<'EOF'

# Fail fast on the remote machine if any command fails
set -e

# Prepare target directory
cd /home/${SSH_USER}
mkdir -p /aysapps

# Ensure a clean setup directory
rm -rf /aysapps/setup

# Remove files that should not be kept or executed
rm -f /home/${SSH_USER}/setup/initial-setup.sh


# === SETUP USER OPERATION SCRIPT ===
# Ensure scripts directory exists and copy the operation script
mkdir -p /home/${SSH_USER}/scripts
cp /home/${SSH_USER}/setup/user-operation /home/${SSH_USER}/scripts/user-operation
rm -f /home/${SSH_USER}/setup/user-operation

# Move setup to the final system location
mv /home/${SSH_USER}/setup /aysapps/setup

# Set root ownership for security and consistency
chown -R root:root /aysapps/setup

EOF"


# === EXECUTE REMOTE SETUP SCRIPTS ===
# Connect via SSH, set permissions, and execute the Docker setup script
echo ""
echo "🚀 Executing Docker setup on remote server..."
ssh -p "$SSH_PORT" -t "${SSH_USER}@${SERVER_IP}" \
"sudo bash -c 'cd /aysapps/setup; \
chmod +x -R .; \
bash ./docker/docker-setup.sh && \
bash ./github/github-setup.sh && \
bash ./project/back-end/project-setup.sh && \
bash ./project/front-end/project-setup.sh && \
bash ./nginx/nginx-setup.sh; \
exec bash'"
