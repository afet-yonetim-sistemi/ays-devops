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

while true; do
  echo ""
  read -p "➡️ Enter server IP (or host): " SERVER_IP
  [[ -n "$SERVER_IP" ]] && break
  echo "Please enter a server IP/host."
done

read -p "➡️ Enter SSH username (default: ubuntu): " SSH_USER
SSH_USER="${SSH_USER:-ubuntu}"

read -p "➡️ Enter SSH port (default: 22): " SSH_PORT
SSH_PORT="${SSH_PORT:-22}"

echo ""
echo "📦 Copying current directory -> ${SSH_USER}@${SERVER_IP}:~/setup"
scp -P "$SSH_PORT" -r . "${SSH_USER}@${SERVER_IP}:~/setup" || exit 1

echo ""
echo "🧱 Moving to /aysapps/setup with sudo..."
ssh -p "$SSH_PORT" -t "${SSH_USER}@${SERVER_IP}" "sudo bash - <<'EOF'
set -e

cd /home/ubuntu

mkdir -p /aysapps

rm -rf /aysapps/setup
rm -f /home/${SSH_USER}/setup/initial-setup.sh
rm -f /home/${SSH_USER}/setup/user-operation

mv /home/${SSH_USER}/setup /aysapps/setup
chown -R root:root /aysapps/setup

EOF"

ssh -p "$SSH_PORT" -t "${SSH_USER}@${SERVER_IP}" \
"sudo bash -c 'cd /aysapps/setup; \
chmod +x -R .; \
bash ./docker/docker-setup.sh; \
exec bash'"
