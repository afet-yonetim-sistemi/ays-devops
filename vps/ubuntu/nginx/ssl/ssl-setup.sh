#!/usr/bin/env bash

# Remove existing script if any
# rm ssl-setup.sh

# Make script executable and run with sudo
# nano ssl-setup.sh
# chmod +x ssl-setup.sh
# sudo ./ssl-setup.sh

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"

# === SSL DIRECTORY SETUP ===
# Check if SSL directory exists, create if needed
if [[ -d /etc/nginx/ssl ]]; then
  echo ""
  echo "✅ '/etc/nginx/ssl' directory already exists. Skipping creation."
else
  echo ""
  echo "Creating '/etc/nginx/ssl' directory..."
  mkdir "/etc/nginx/ssl"
fi


# === ORIGIN CERTIFICATE INPUT ===
# Ask for Origin Certificate until a non-empty value is provided
while true; do
  echo ""
  read -p "➡️ Paste your Origin Certificate: " ORIGIN_CERTIFICATE
  [[ -n "$ORIGIN_CERTIFICATE" ]] && break
  echo "Please paste your Origin Certificate."
done

echo "${ORIGIN_CERTIFICATE}" > /aysapps/setup/nginx/ssl/origin.crt


# === ORIGIN KEY INPUT ===
# Ask for Origin Key until a non-empty value is provided
while true; do
  echo ""
  read -p "➡️ Paste your Origin Key: " ORIGIN_KEY
  [[ -n "$ORIGIN_KEY" ]] && break
  echo "Please paste your Origin Key."
done

echo "${ORIGIN_KEY}" > /aysapps/setup/nginx/ssl/origin.key


# === MOVE SSL FILES AND RELOAD NGINX ===
# Move SSL configuration files to Nginx directory and reload service
echo ""
echo "📦 Moving SSL configuration files..."
mv /aysapps/setup/nginx/ssl/origin.crt /etc/nginx/ssl/origin.crt
mv /aysapps/setup/nginx/ssl/origin.key /etc/nginx/ssl/origin.key

echo ""
echo "🔍 Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "🔄 Reloading Nginx service..."
sudo systemctl reload nginx

echo ""
echo "✅ SSL setup completed and Nginx reloaded successfully."
