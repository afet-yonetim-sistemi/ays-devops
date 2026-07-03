#!/usr/bin/env bash

# Remove existing script if any
# rm nginx-setup.sh

# Make script executable and run with sudo
# nano nginx-setup.sh
# chmod +x nginx-setup.sh
# sudo ./nginx-setup.sh

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"

# === CHECK NGINX INSTALLATION ===
# Verify if Nginx is already installed on the system
if command -v nginx >/dev/null 2>&1; then
  echo ""
  echo "✅ Nginx already installed: $(nginx -v 2>&1)"
  exit 0
fi


# === INSTALL NGINX ===
# Install Nginx package from Ubuntu repositories
echo ""
echo "📦 Installing Nginx..."
sudo apt install nginx


# === ENABLE NGINX SERVICE ===
# Enable Nginx to start automatically on system boot
echo ""
echo "⚙️ Enabling Nginx service..."
sudo systemctl enable nginx


# === SSL SETUP ===
# Execute SSL certificate setup script
echo ""
echo "🔐 Starting SSL configuration..."
sudo ./ssl/ssl-setup.sh


# === SERVER NAMES CONFIGURATION ===
# Ask for server names for each configuration file
echo ""
echo "📝 Configure server names for each service..."

while true; do
  echo ""
  read -p "➡️ Enter server names for Back-End (ays-be.conf) [e.g., api.example.com api-test.example.com]: " AYS_BE_SERVER_NAMES
  [[ -n "$AYS_BE_SERVER_NAMES" ]] && break
  echo "Please enter the server names!"
done

while true; do
  echo ""
  read -p "➡️ Enter server names for Institution Front-End (ays-fe-institution.conf) [e.g., institution.example.com]: " AYS_FE_INSTITUTION_SERVER_NAMES
  [[ -n "$AYS_FE_INSTITUTION_SERVER_NAMES" ]] && break
  echo "Please enter the server names!"
done

while true; do
  echo ""
  read -p "➡️ Enter server names for Landing Front-End (ays-fe-landing.conf) [e.g., landing.example.com]: " AYS_FE_LANDING_SERVER_NAMES
  [[ -n "$AYS_FE_LANDING_SERVER_NAMES" ]] && break
  echo "Please enter the server names!"
done

while true; do
  echo ""
  read -p "➡️ Enter server names for Landing New Front-End (ays-fe-landing-new.conf) [e.g., landing-new.example.com]: " AYS_FE_LANDING_NEW_SERVER_NAMES
  [[ -n "$AYS_FE_LANDING_NEW_SERVER_NAMES" ]] && break
  echo "Please enter the server names!"
done

while true; do
  echo ""
  read -p "➡️ Enter server names for Landing Production Front-End (ays-fe-landing-production.conf) [e.g., landing-production.example.com]: " AYS_FE_LANDING_PRODUCTION_SERVER_NAMES
  [[ -n "$AYS_FE_LANDING_PRODUCTION_SERVER_NAMES" ]] && break
  echo "Please enter the server names!"
done


# === UPDATE CONFIGURATION FILES ===
# Replace {{SERVER_NAMES}} placeholders with user-provided values
echo ""
echo "🔧 Updating configuration files with server names..."

sed -i "s/{{SERVER_NAMES}}/${AYS_BE_SERVER_NAMES}/g" /aysapps/setup/nginx/conf/ays-be.conf
sed -i "s/{{SERVER_NAMES}}/${AYS_FE_INSTITUTION_SERVER_NAMES}/g" /aysapps/setup/nginx/conf/ays-fe-institution.conf
sed -i "s/{{SERVER_NAMES}}/${AYS_FE_LANDING_SERVER_NAMES}/g" /aysapps/setup/nginx/conf/ays-fe-landing.conf
sed -i "s/{{SERVER_NAMES}}/${AYS_FE_LANDING_NEW_SERVER_NAMES}/g" /aysapps/setup/nginx/conf/ays-fe-landing-new.conf
sed -i "s/{{SERVER_NAMES}}/${AYS_FE_LANDING_PRODUCTION_SERVER_NAMES}/g" /aysapps/setup/nginx/conf/ays-fe-landing-production.conf


# === MOVE CONFIGURATION FILES ===
# Move Nginx configuration files to system directories
echo ""
echo "📦 Moving Nginx configuration files..."
mv /aysapps/setup/nginx/conf/* /etc/nginx/conf.d/
mv /aysapps/setup/nginx/nginx.conf /etc/nginx/nginx.conf


# === DOMAIN CONFIGURATION REMINDER ===
# 🚨 IMPORTANT: Configure DNS A records before running this script.
# For detailed instructions, see: vps/ubuntu/nginx/README.md


# === CLOUDFLARE REAL IP CONFIGURATION ===
# Fetch Cloudflare's IP ranges and write them to cloudflare-realip.conf
# so Nginx can resolve the real client IP from the CF-Connecting-IP header
echo ""
echo "☁️ Configuring Cloudflare real IP ranges..."
{
  for ip in $(curl -s https://www.cloudflare.com/ips-v4); do echo "set_real_ip_from $ip;"; done
  for ip in $(curl -s https://www.cloudflare.com/ips-v6); do echo "set_real_ip_from $ip;"; done
  echo "real_ip_header CF-Connecting-IP;"
} | sudo tee /etc/nginx/cloudflare-realip.conf


# === TEST AND RESTART NGINX ===
# Test configuration and restart Nginx service
echo ""
echo "🔍 Testing Nginx configuration..."
sudo nginx -t

echo ""
echo "🔄 Restarting Nginx service..."
sudo systemctl restart nginx

echo ""
echo "✅ Nginx setup completed successfully."
