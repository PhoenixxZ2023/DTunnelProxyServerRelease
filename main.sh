#!/bin/bash

# DTunnel Proxy Management Script
# Author: Your Name
# Date: February 5, 2024

TOKEN_FILE="$HOME/.proxy_token"
PROXY_BIN="/usr/bin/proxy"

# Function to load token from file
load_token_from_file() {
    local token=$(<"$TOKEN_FILE")
    echo "$token"
}

# Function to check if a port is in use
is_port_in_use() {
    local port=$1
    nc -z localhost "$port"
    return $?
}

# Function to validate token
validate_token() {
    local token="$1"
    "$PROXY_BIN" --token "$token" --validate >/dev/null
    return $?
}

# Function to check and set token
check_token() {
    if [ ! -f "$TOKEN_FILE" ]; then
        echo -e "\033[1;33mAccess token not found\033[0m"
        while true; do
            read -rp "$(prompt 'Please enter your token: ')" token
            echo "$token" > "$TOKEN_FILE"
            echo -e "\n\033[1;32mToken saved to $TOKEN_FILE\033[0m"
            return
        done
    fi
}

# Function to prompt with formatting
prompt() {
    echo -e "\033[1;33m$1\033[0m"
}

# ... (Other functions remain unchanged)

# Main function
main() {
    clear
    check_token

    echo -e "\033[1;34m╔═════════════════════════════╗\033[0m"
    echo -e "\033[1;34m║\033[1;41m\033[1;32m      DTunnel Proxy Menu     \033[0m\033[1;34m║"
    echo -e "\033[1;34m║═════════════════════════════║\033[0m"

    show_ports_in_use

    local option
    echo -e "\033[1;34m║\033[1;36m[\033[1;32m01\033[1;36m] \033[1;32m• \033[1;31mOPEN PORT              \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m02\033[1;36m] \033[1;32m• \033[1;31mCLOSE PORT             \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m03\033[1;36m] \033[1;32m• \033[1;31mRESTART PORT           \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m04\033[1;36m] \033[1;32m• \033[1;31mMONITOR               \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m00\033[1;36m] \033[1;32m• \033[1;31mEXIT                  \033[1;34m║"
    echo -e "\033[1;34m╚═════════════════════════════╝\033[0m"

    read -rp "$(prompt 'Select an option: ')" option

    case "$option" in
        1) start_proxy ;;
        2) stop_proxy ;;
        3) restart_proxy ;;
        4) show_proxy_log ;;
        0) exit_proxy_menu ;;
        *) echo -e "\033[1;31mInvalid option. Please try again.\033[0m" ; pause_prompt ;;
    esac

    main
}

main
