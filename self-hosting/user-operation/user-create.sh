#!/usr/bin/env bash

# Remove existing script if any
# rm user-create.sh

# Make script executable and run with sudo
# nano user-create.sh
# chmod +x user-create.sh
# sudo ./user-create.sh

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

cd /home 2>/dev/null || {
  echo "Cannot cd to /home. Please check your system."
  exit 1
}

trim() {
  local s="$1"
  s="${s//$'\r'/}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

while true; do
  read -r -p "➡️ Enter username to create: " USERNAME
  USERNAME="$(trim "$USERNAME")"

  if [[ -z "$USERNAME" ]]; then
    echo "Please enter a username."
    continue
  fi

  if ! [[ "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    echo "Invalid username: [$USERNAME] (raw: $(printf '%q' "$USERNAME"))"
    echo "Use: lowercase letters, digits, '_' or '-', and start with a letter or '_'."
    continue
  fi

  if getent passwd "$USERNAME" >/dev/null 2>&1; then
    echo "'$USERNAME' already exists. Aborting."
    exit 1
  fi

  if [[ -d "/home/$USERNAME" ]]; then
    echo "/home/$USERNAME already exists. Aborting."
    exit 1
  fi

  break
done

# Admin mi? (optional sudo)
while true; do
  read -r -p "➡️ Should this user be admin (sudo)? (y/n): " IS_ADMIN
  IS_ADMIN="$(trim "$IS_ADMIN")"
  case "$IS_ADMIN" in
    [Yy]) IS_ADMIN="y"; break ;;
    [Nn]) IS_ADMIN="n"; break ;;
    *) echo "Invalid choice, please enter 'y' or 'n'." ;;
  esac
done

echo ""
echo "User creation starting..."
sleep 1

adduser --disabled-password --gecos "" "$USERNAME" || {
  echo "adduser failed. Aborting."
  exit 1
}

if [[ "$IS_ADMIN" == "y" ]]; then
  usermod -aG sudo "$USERNAME" || {
    echo "usermod failed. Aborting."
    exit 1
  }
fi

passwd -d "$USERNAME" >/dev/null 2>&1 || {
  echo "passwd -d failed. Aborting."
  exit 1
}

echo ""

if [[ "$IS_ADMIN" == "y" ]]; then
  echo "'$USERNAME' created and added to sudo group!"
else
  echo "'$USERNAME' created (non-admin)."
fi

echo ""
