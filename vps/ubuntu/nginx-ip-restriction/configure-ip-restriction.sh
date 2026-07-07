#!/bin/bash

# ==============================================================================
# AYS - IP Restriction Configuration Script
# ==============================================================================

SERVER_CONF_PATH="/etc/nginx/conf.d/ays_ip_restriction.conf"

# If local, write to project folder so it doesn't throw an error
if [ -d "/etc/nginx/conf.d" ]; then
    NGINX_CONF_PATH=$SERVER_CONF_PATH
else
    NGINX_CONF_PATH="./ays_ip_restriction.conf"
fi

# Allowed IPs
ALLOWED_IPS=(
    "127.0.0.1"      # Lokal makine
    "192.168.1.50"   # Örnek İç Ağ IP'si
    "203.0.113.195"  # Örnek Güvenli Dış IP
)

echo " Starting AYS IP restriction configuration..."

# Clear and reset the old file
echo "# ==================================================" > "$NGINX_CONF_PATH"
echo "# AYS ALLOWED IP LIST (Auto-generated)" >> "$NGINX_CONF_PATH"
echo "# ==================================================" >> "$NGINX_CONF_PATH"

# Add allowed IPs to the file
for ip in "${ALLOWED_IPS[@]}"; do
    echo "allow $ip;" >> "$NGINX_CONF_PATH"
    echo " Added allowed IP: $ip"
done

echo "deny all;" >> "$NGINX_CONF_PATH"
echo " Deny all rule added for all other IPs."

echo "--------------------------------------------------"
echo " Testing and reloading Nginx..."

if command -v nginx &> /dev/null; then
    nginx -t && systemctl reload nginx
    echo "✅ IP restrictions are live now!"
else
    echo "⚠️ Warning: Nginx not found. Created the file locally instead."
    echo " File path: $NGINX_CONF_PATH"
fi
