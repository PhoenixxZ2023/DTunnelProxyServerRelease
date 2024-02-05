#!/bin/bash

TOKEN_FILE="$HOME/.proxy_token"
PROXY_BIN="/usr/bin/proxy"

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

get_yes_no_response() {
    local response
    local question="$1" 
    while true; do
        read -rp "$question (s/n): " -ei n response
        case "$response" in
            [sS]) return 0 ;;
            [nN]) return 1 ;;
            *) echo -e "\033[1;31mResposta inválida. Tente novamente.\033[0m" ;;
        esac
    done
}

# ... (other functions remain unchanged)

check_token() {
    echo -e "\033[1;33mToken de acesso não verificado\033[0m"
    echo -e "\033[1;32mContinuando sem verificar o token...\033[0m"
    sleep 1
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
