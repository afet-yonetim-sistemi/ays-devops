#!/usr/bin/env bash

# Remove existing script if any
# rm user-delete.sh

# Make script executable and run with sudo
# nano user-delete.sh
# chmod +x user-delete.sh
# bash ./user-delete.sh

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
# Ensure the script is executed as root (required for user deletion)
if [[ "$EUID" -ne 0 ]]; then
  echo "This script must be run as root. Try: sudo bash $0"
  exit 1
fi


# === WORKING DIRECTORY SAFETY CHECK ===
# Move to /home and fail early if the directory is not accessible
cd /home 2>/dev/null || {
  echo "Cannot cd to /home. Please check your system."
  exit 1
}


# === HELPER FUNCTION: INPUT SANITIZATION ===
# Trim carriage returns and leading/trailing whitespace from input
trim() {
  local s="$1"
  s="${s//$'\r'/}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}


# === USERNAME INPUT & VALIDATION ===
# Repeatedly ask for a valid username to delete
while true; do
  read -r -p "➡️ Enter username to delete: " USERNAME
  USERNAME="$(trim "$USERNAME")"

  # Reject empty input
  if [[ -z "$USERNAME" ]]; then
    echo "Please enter a username."
    continue
  fi

  # Enforce valid Linux username format
  if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: [$USERNAME]"
    echo "Use: lowercase letters, digits, '_' or '-', and start with a letter or '_'."
    continue
  fi

  # Explicitly refuse to delete the root user
  if [[ "$USERNAME" == "root" ]]; then
    echo "Refusing to delete 'root'."
    exit 1
  fi

  # Ensure the user actually exists on the system
  if ! getent passwd "$USERNAME" >/dev/null 2>&1; then
    echo "User '$USERNAME' does not exist. Aborting."
    exit 1
  fi

  # All checks passed
  break
done


# === DELETION PRE-CHECKS ===
echo ""
echo "User deletion starting..."
echo ""

# Warn if the user has running processes
if pgrep -u "$USERNAME" >/dev/null 2>&1; then
  echo "Warning: user '$USERNAME' has running processes."
  echo "If deletion fails, stop them with: pkill -u $USERNAME"
  echo ""
fi


# === CLEAN UP SUDOERS ENTRY ===
# Remove per-user sudo configuration if it exists
if [[ -f "/etc/sudoers.d/$USERNAME" ]]; then
  rm -f "/etc/sudoers.d/$USERNAME"
fi


# === USER DELETION ===
# Delete the user and their home directory
if userdel -r "$USERNAME" 2>/dev/null; then
  echo "'$USERNAME' deleted successfully."
else
  echo "userdel failed."
  echo "Try (carefully): userdel -r -f $USERNAME"
  exit 1
fi

echo ""
