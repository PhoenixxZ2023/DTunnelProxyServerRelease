#!/bin/bash

PROXY_BIN="/usr/bin/proxy"
TOKEN_FILE="$HOME/.proxy_token"

# Function to check if a port is in use
is_port_in_use() {
    local port=$1
    nc -z localhost "$port"
    return $?
}

# Function to display prompts with yellow text
prompt() {
    echo -e "\033[1;33m$1\033[0m"
}

# Function to get a yes/no response
get_yes_no_response() {
    local response question="$1"
    while true; do
        read -rp "$(prompt "$question (s/n): ")" -ei n response
        case "$response" in
            [sS]) return 0 ;;
            [nN]) return 1 ;;
            *) echo -e "\033[1;31mResposta inválida. Tente novamente.\033[0m" ;;
        esac
    done
}

# Function to display a pause prompt
pause_prompt() {
    read -rp "$(prompt 'Pressione Enter para continuar...')" voidResponse
}

# Function to get a valid port
get_valid_port() {
    while true; do
        read -rp "$(prompt 'Porta: ')" port
        if ! [[ "$port" =~ ^[0-9]+$ ]] || [ "$port" -le 0 ] || [ "$port" -gt 65535 ] || is_port_in_use "$port"; then
            echo -e "\033[1;31mPorta inválida ou em uso. Tente novamente.\033[0m"
        else
            break
        fi
    done
    echo "$port"
}

# Function to start the proxy
start_proxy() {
    local port=$(get_valid_port)
    local protocol cert_path response ssh_only service_name service_file
    local proxy_log_file="/var/log/proxy-$port.log"

    if get_yes_no_response "$(prompt 'Habilitar o HTTPS?')"; then
        protocol="--https"
        read -rp "$(prompt 'Caminho do Certificado SSL (HTTPS):')" cert_path
        cert_path="--cert $cert_path"
    else
        protocol="--http"
        cert_path=""
    fi

    read -rp "$(prompt 'Status HTTP (Padrão: @DuTra01): ')" response
    response="${response:-@DuTra01}"

    ssh_only=""
    if get_yes_no_response "$(prompt 'Habilitar somente SSH?')"; then
        ssh_only="--ssh-only"
    fi

    service_name="proxy-$port"
    service_file="/etc/systemd/system/$service_name.service"
    cat >"$service_file" <<EOF
[Unit]
Description=DTunnel Proxy Server on port $port
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$(pwd)
ExecStart=$PROXY_BIN --token \$(cat "$TOKEN_FILE") $protocol --port $port $ssh_only --buffer-size 32768 --workers 2500 $cert_path --response $response --log-file $proxy_log_file
StandardOutput=null
StandardOutput=null
Restart=always
TasksMax=5000

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl start "$service_name"
    systemctl enable "$service_name"

    echo -e "\033[1;32mProxy iniciado na porta $port.\033[0m"
    pause_prompt
}

# Function to restart the proxy
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

# Function to stop the proxy
stop_proxy() {
    local port
    read -rp "$(prompt 'Porta: ')" port
    local service_name="proxy-$port"

    systemctl stop "$service_name"
    systemctl disable "$service_name"
    systemctl daemon-reload
    rm "/etc/systemd/system/$service_name.service"

    echo -e "\033[1;32mProxy na porta $port foi fechado.\033[0m"
    pause_prompt
}

# Function to show proxy logs
show_proxy_log() {
    local port proxy_log_file

    read -rp "$(prompt 'Porta: ')" port
    proxy_log_file="/var/log/proxy-$port.log"

    if [[ ! -f $proxy_log_file ]]; then
        echo -e "\033[1;31mArquivo de log não encontrado\033[0m"
        pause_prompt
        return
    fi

    trap 'break' INT

    while :; do
        clear
        cat "$proxy_log_file"

        echo -e "\nPressione \033[1;33mCtrl+C\033[0m para voltar ao menu."
        sleep 1
    done

    trap - INT
}

# Function to exit the proxy menu
exit_proxy_menu() {
    echo -e "\033[1;31mSaindo...\033[0m"
    exit 0
}

# Main function
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

# Run the main function
main
