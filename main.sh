#!/bin/bash

PROXY_BIN="/usr/bin/proxy"

is_port_in_use() {
    local port=$1
    nc -z localhost "$port"
    return $?
}

prompt() {
    echo -e "\033[1;33m$1\033[0m"
}

# ... (Other functions remain unchanged)

start_proxy() {
    local port=$(get_valid_port)
    local protocol cert_path response ssh_only service_name service_file
    local proxy_log_file="/var/log/proxy-$port.log"

    # ... (Other code remains unchanged)
}

restart_proxy() {
    local port
    read -rp "$(prompt 'Porta: ')" port

    local service_name="proxy-$port"
    if ! systemctl is-active "$service_name" >/dev/null; then
        echo -e "\033[1;31mProxy na porta $port não está ativo.\033[0m"
        pause_prompt
        return
    fi

    systemctl restart "$service_name"

    echo -e "\033[1;32mProxy na porta $port reiniciado.\033[0m"
    pause_prompt
}

# ... (Other functions remain unchanged)

main() {
    clear

    echo -e "\033[1;34m╔═════════════════════════════╗\033[0m"
    echo -e "\033[1;34m║\033[1;41m\033[1;32m      DTunnel Proxy Menu     \033[0m\033[1;34m║"
    echo -e "\033[1;34m║═════════════════════════════║\033[0m"

    show_ports_in_use

    local option
    echo -e "\033[1;34m║\033[1;36m[\033[1;32m01\033[1;36m] \033[1;32m• \033[1;31mABRIR PORTA           \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033[1;32m02\033[1;36m] \033[1;32m• \033[1;31mFECHAR PORTA          \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033[1;32m03\033[1;36m] \033[1;32m• \033[1;31mREINICIAR PORTA       \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033[1;32m04\033[1;36m] \033[1;32m• \033[1;31mMONITOR               \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033[1;32m00\033[1;36m] \033[1;32m• \033[1;31mSAIR                  \033[1;34m║"
    echo -e "\033[1;34m╚═════════════════════════════╝\033[0m"
    read -rp "$(prompt 'Escolha uma opção: ')" option

    case "$option" in
        1) start_proxy ;;
        2) stop_proxy ;;
        3) restart_proxy ;;
        4) show_proxy_log ;;
        0) exit_proxy_menu ;;
        *) echo -e "\033[1;31mOpção inválida. Tente novamente.\033[0m" ; pause_prompt ;;
    esac

    main
}

main
