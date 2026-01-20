#!/usr/bin/env bash

# Remove existing script if any
# rm github-setup.sh

# Make script executable and run with sudo
# nano github-setup.sh
# chmod +x github-setup.sh
# sudo ./github-setup.sh

echo "
     ___  ____    ____  _______,
    /   \ \   \  /   / /       |
   /  ^  \ \   \/   / |   (----'
  /  /_\  \ \_    _/   \   \\
 /  _____  \  |  | .----)   |
/__/     \__\ |__| |_______/
:: AYS | Afet Yönetim Sistemi ::
"


# === CHECK IF GITHUB CLI IS ALREADY INSTALLED ===
# If gh command exists, update it and exit
if command -v gh >/dev/null 2>&1; then
  echo ""
  echo "✅ GitHub CLI (gh) installed. Checking for updates..."
  sudo apt update && sudo apt install -y gh
  echo "✅ GitHub CLI updated (if an update was available). Current version: $(gh --version | head -n1)"
  exit 0
fi


# === INSTALL GITHUB CLI ===
# Install wget if not available, then install GitHub CLI with its GPG key and repository
(type -p wget >/dev/null || (sudo apt update && sudo apt install wget -y)) \
	&& sudo mkdir -p -m 755 /etc/apt/keyrings \
	&& out=$(mktemp) && wget -nv -O$out https://cli.github.com/packages/githubcli-archive-keyring.gpg \
	&& cat $out | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
	&& sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
	&& sudo mkdir -p -m 755 /etc/apt/sources.list.d \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& sudo apt update \
	&& sudo apt install gh -y


# === GITHUB PERSONAL ACCESS TOKEN INPUT ===
# Ask for GitHub Personal Access Token until a non-empty value is provided
while true; do
  echo ""
  read -p "➡️ Paste your Personal Access Token: " GITHUB_ACCESS_TOKEN
  if [[ -n "$GITHUB_ACCESS_TOKEN" ]]; then
    break
  fi
  echo "Please paste your Personal Access Token."
done


# === SAVE TOKEN AND AUTHENTICATE ===
# Save the token to a file and authenticate GitHub CLI
mkdir -p /aysapps/setup/github
echo "${GITHUB_ACCESS_TOKEN}" > /aysapps/setup/github/access-token.txt

gh auth login --with-token < /aysapps/setup/github/access-token.txt
