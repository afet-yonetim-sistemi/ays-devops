#!/usr/bin/env bash

# Remove existing script if any
# rm ssh-configure.sh

# Make script executable and run with sudo
# nano ssh-configure.sh
# chmod +x ssh-configure.sh
# bash ./ssh-configure.sh

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"

# === ROOT PERMISSION CHECK ===
# Ensure the script is executed as root (required for SSH and file ownership changes)
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root. Try: sudo bash $0"
  exit 1
fi


# === HELPER FUNCTION: INPUT NORMALIZATION ===
# Trim carriage returns and leading/trailing whitespace from user input
trim() {
  local s="$1"
  s="${s//$'\r'/}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}


# === USER SELECTION & VALIDATION ===
# Ask for a valid, non-root, existing system user
while true; do
  read -r -p "➡️ Enter username for SSH configuration: " USERNAME
  USERNAME="$(trim "$USERNAME")"

  # Reject empty input
  if [[ -z "$USERNAME" ]]; then
    echo "Please enter a username."
    continue
  fi

  # Enforce valid Linux username rules
  if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username. Use: lowercase letters, digits, '_' or '-', and start with a letter or '_'."
    continue
  fi

  # Explicitly refuse to operate on root
  if [[ "$USERNAME" == "root" ]]; then
    echo "Refusing to operate on 'root'."
    exit 1
  fi

  # Ensure the user exists on the system
  if ! getent passwd "$USERNAME" >/dev/null 2>&1; then
    echo "'$USERNAME' not found."
    continue
  fi

  break
done


# === HOME DIRECTORY RESOLUTION ===
# Determine the user's home directory from system account information
HOME_DIR="$(getent passwd "$USERNAME" | cut -d: -f6)"
if [[ -z "$HOME_DIR" ]]; then
  echo "Could not determine home directory for '$USERNAME'. Aborting."
  exit 1
fi


# === SSH PUBLIC KEY INPUT ===
# Prompt until a non-empty SSH public key is provided
while true; do
  read -r -p "➡️ Paste user's SSH public key (single line): " PUBKEY
  PUBKEY="$(trim "$PUBKEY")"
  if [[ -n "$PUBKEY" ]]; then
    break
  fi
  echo "Please paste a public key."
done


# === SSH DIRECTORY & FILE PATHS ===
# Define SSH directory and authorized_keys path
SSH_DIR="$HOME_DIR/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"


# === SSH DIRECTORY SETUP ===
# Create .ssh directory with correct ownership and permissions
echo ""
echo "Setting up authorized_keys..."
echo ""

mkdir -p "$SSH_DIR" || { echo "Failed to create $SSH_DIR"; exit 1; }
chown "$USERNAME:$USERNAME" "$SSH_DIR" || { echo "chown failed on $SSH_DIR"; exit 1; }
chmod 700 "$SSH_DIR" || { echo "chmod failed on $SSH_DIR"; exit 1; }


# === EXISTING authorized_keys BACKUP ===
# If an authorized_keys file exists, back it up with a timestamp
if [[ -f "$AUTH_KEYS" ]]; then
  TS="$(date +%Y%m%d-%H%M%S)"
  BACKUP="${AUTH_KEYS}.backup.${TS}"
  cp -a "$AUTH_KEYS" "$BACKUP" || { echo "Backup failed: $BACKUP"; exit 1; }
  chown "$USERNAME:$USERNAME" "$BACKUP" 2>/dev/null || true
  chmod 600 "$BACKUP" 2>/dev/null || true
  echo "Backup created: $BACKUP"
fi


# === authorized_keys RESET & PERMISSIONS ===
# Reset authorized_keys file and enforce secure ownership and permissions
: > "$AUTH_KEYS" || { echo "Failed to create/reset $AUTH_KEYS"; exit 1; }
chown "$USERNAME:$USERNAME" "$AUTH_KEYS" || { echo "chown failed on $AUTH_KEYS"; exit 1; }
chmod 600 "$AUTH_KEYS" || { echo "chmod failed on $AUTH_KEYS"; exit 1; }


# === WRITE SSH PUBLIC KEY ===
# Write the provided public key to authorized_keys
printf '%s\n' "$PUBKEY" >> "$AUTH_KEYS" || { echo "Failed to write key to $AUTH_KEYS"; exit 1; }
echo "Public key written to authorized_keys."


# === FINAL STATUS ===
echo ""
echo "SSH has been configured for '$USERNAME'"
echo ""
