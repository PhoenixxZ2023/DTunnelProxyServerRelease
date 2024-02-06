#!/bin/bash

# Define variables for URLs and file paths
MAIN_URL="https://github.com/PhoenixxZ2023/DTunnelProxyServerRelease/raw/main/main.sh"
PROXY_URL="https://github.com/PhoenixxZ2023/DTunnelProxyServerRelease/raw/main/build/$(uname -i)/proxy"
MAIN_FILE="/usr/bin/main"
PROXY_FILE="/usr/bin/proxy"

# Remove existing files
rm -f "$MAIN_FILE" "$PROXY_FILE"

# Download main.sh and proxy
curl -s -L -o "$MAIN_FILE" "$MAIN_URL"
curl -s -L -o "$PROXY_FILE" "$PROXY_URL"

# Give execute permissions
chmod +x "$MAIN_FILE" "$PROXY_FILE"

# Clear the terminal and display execution instructions
clear && echo -e "\033[1;31mExecute: \033[1;32mmain\033[0m"
