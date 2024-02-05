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

show_ports_in_use() {
    local ports_in_use=$(systemctl list-units --all --plain --no-legend | grep -oE 'proxy-[0-9]+' | cut -d'-' -f2)
    if [ -n "$ports_in_use" ]; then
        ports_in_use=$(echo "$ports_in_use" | tr '\n' ' ')
        echo -e "\033[1;34m║\033[1;32mEm uso:\033[1;33m $(printf '%-21s' "$ports_in_use")\033[1;34m║\033[0m"
        echo -e "\033[1;34m║═════════════════════════════║\033[0m"
    fi
}

pause_prompt() {
    read -rp "$(prompt 'Enter pra continuar...')" voidResponse
}

get_valid_port() {
    while true; do
        read -rp "$(prompt 'Porta: ')" port
        if ! [[ "$port" =~ ^[0-9]+$ ]]; then
            echo -e "\033[1;31mPorta inválido.\033[0m"
        elif [ "$port" -le 0 ] || [ "$port" -gt 65535 ]; then
            echo -e "\033[1;31mPorta fora do intervalo permitido.\033[0m"
        elif is_port_in_use "$port"; then
            echo -e "\033[1;31mPorta em uso.\033[0m"
        else
            break
        fi
    done
    echo "$port"
}

start_proxy() {
    local port=$(get_valid_port)
    local protocol cert_path response ssh_only service_name service_file
    local proxy_log_file="/var/log/proxy-$port.log"

    if get_yes_no_response "$(prompt 'Habilitar o HTTPS?')"; then
        protocol="--https"
        read -rp "$(prompt 'Certificado SSL (HTTPS):')" cert_path
        cert_path="--cert $cert_path"
    else
        protocol="--http"
        cert_path=""
    fi

    read -rp "$(prompt 'Status HTTP (Padrão: @DuTra01): ')" response
    response="${response:-@Buga-ssh}"

    if get_yes_no_response "$(prompt 'Habilitar somente SSH?')"; then
        ssh_only="--ssh-only"
    else
        ssh_only=""
    fi

    service_name="proxy-$port"
    service_file="/etc/systemd/system/$service_name.service"
    cat > $service_file <<EOF
[Unit]
Description=DTunnel Proxy Server on port $port
After=network.target

[Service]
Type=simple
User=$(whoami)
WorkingDirectory=$(pwd)
ExecStart=$PROXY_BIN --port $port $protocol $ssh_only --buffer-size 32768 --workers 2500 $cert_path --response $response --log-file $proxy_log_file
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

stop_proxy() {
    show_ports_in_use

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


exit_proxy_menu() {
    echo -e "\033[1;31mSaindo...\033[0m"
    exit 0
}

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
