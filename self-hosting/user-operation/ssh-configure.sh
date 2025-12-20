#!/usr/bin/env bash

# Remove existing script if any
# rm ssh-configure.sh

# Make script executable and run with sudo
# nano ssh-configure.sh
# chmod +x ssh-configure.sh
# sudo ./ssh-configure.sh

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"

if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root. Try: sudo bash $0"
  exit 1
fi

trim() {
  local s="$1"
  s="${s//$'\r'/}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

while true; do
  read -r -p "➡️ Enter username for SSH configuration: " USERNAME
  USERNAME="$(trim "$USERNAME")"

  if [[ -z "$USERNAME" ]]; then
    echo "Please enter a username."
    continue
  fi

  if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username. Use: lowercase letters, digits, '_' or '-', and start with a letter or '_'."
    continue
  fi

  if [[ "$USERNAME" == "root" ]]; then
    echo "Refusing to operate on 'root'."
    exit 1
  fi

  if ! getent passwd "$USERNAME" >/dev/null 2>&1; then
    echo "'$USERNAME' not found."
    continue
  fi

  break
done

HOME_DIR="$(getent passwd "$USERNAME" | cut -d: -f6)"
if [[ -z "$HOME_DIR" ]]; then
  echo "Could not determine home directory for '$USERNAME'. Aborting."
  exit 1
fi

while true; do
  read -r -p "➡️ Paste user's SSH public key (single line): " PUBKEY
  PUBKEY="$(trim "$PUBKEY")"
  if [[ -n "$PUBKEY" ]]; then
    break
  fi
  echo "Please paste a public key."
done

SSH_DIR="$HOME_DIR/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

echo ""
echo "Setting up authorized_keys..."
echo ""

mkdir -p "$SSH_DIR" || { echo "Failed to create $SSH_DIR"; exit 1; }
chown "$USERNAME:$USERNAME" "$SSH_DIR" || { echo "chown failed on $SSH_DIR"; exit 1; }
chmod 700 "$SSH_DIR" || { echo "chmod failed on $SSH_DIR"; exit 1; }

if [[ -f "$AUTH_KEYS" ]]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  BACKUP="${AUTH_KEYS}.backup.${TS}"
  cp -a "$AUTH_KEYS" "$BACKUP" || { echo "Backup failed: $BACKUP"; exit 1; }
  chown "$USERNAME:$USERNAME" "$BACKUP" 2>/dev/null || true
  chmod 600 "$BACKUP" 2>/dev/null || true
  echo "Backup created: $BACKUP"
fi

: > "$AUTH_KEYS" || { echo "Failed to create/reset $AUTH_KEYS"; exit 1; }
chown "$USERNAME:$USERNAME" "$AUTH_KEYS" || { echo "chown failed on $AUTH_KEYS"; exit 1; }
chmod 600 "$AUTH_KEYS" || { echo "chmod failed on $AUTH_KEYS"; exit 1; }

printf '%s\n' "$PUBKEY" >> "$AUTH_KEYS" || { echo "Failed to write key to $AUTH_KEYS"; exit 1; }
echo "Public key written to authorized_keys."

echo ""
echo "SSH has been configured for '$USERNAME'"
echo ""
