#!/bin/bash

# Script de Gerenciamento do Proxy DTunnel
# Autor: Seu Nome
# Data: 5 de fevereiro de 2024

ARQUIVO_TOKEN="$HOME/.proxy_token"
PROXY_BIN="/usr/bin/proxy"

# Função para carregar o token do arquivo
carregar_token_do_arquivo() {
    local token=$(<"$ARQUIVO_TOKEN")
    echo "$token"
}

# Função para verificar se uma porta está em uso
porta_em_uso() {
    local porta=$1
    nc -z localhost "$porta"
    return $?
}

# Função para validar o token
validar_token() {
    local token="$1"
    "$PROXY_BIN" --token "$token" --validate >/dev/null
    return $?
}

# Função para verificar e definir o token
verificar_token() {
    if [ ! -f "$ARQUIVO_TOKEN" ]; then
        echo -e "\033[1;33mToken de acesso não encontrado\033[0m"
        while true; do
            read -rp "$(prompt 'Por favor, insira seu token: ')" token
            echo "$token" > "$ARQUIVO_TOKEN"
            echo -e "\n\033[1;32mToken salvo em $ARQUIVO_TOKEN\033[0m"
            return
        done
    fi
}

# Função para prompt com formatação
prompt() {
    echo -e "\033[1;33m$1\033[0m"
}

# ... (Outras funções permanecem inalteradas)

# Função principal
principal() {
    clear
    verificar_token

    echo -e "\033[1;34m╔═════════════════════════════╗\033[0m"
    echo -e "\033[1;34m║\033[1;41m\033[1;32m      Menu do Proxy DTunnel    \033[0m\033[1;34m║"
    echo -e "\033[1;34m║═════════════════════════════║\033[0m"

    mostrar_portas_em_uso

    local opcao
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m01\033[1;36m] \033[1;32m• \033[1;31mABRIR PORTA              \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m02\033[1;36m] \033[1;32m• \033[1;31mFECHAR PORTA             \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m03\033[1;36m] \033[1;32m• \033[1;31mREINICIAR PORTA          \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m04\033[1;36m] \033[1;32m• \033[1;31mMONITORAR               \033[1;34m║"
    echo -e "\033[1;34m║\033[1;36m[\033;1;32m00\033[1;36m] \033[1;32m• \033[1;31mSAIR                   \033[1;34m║"
    echo -e "\033[1;34m╚═════════════════════════════╝\033[0m"

    read -rp "$(prompt 'Selecione uma opção: ')" opcao

    case "$opcao" in
        1) iniciar_proxy ;;
        2) parar_proxy ;;
        3) reiniciar_proxy ;;
        4) mostrar_log_proxy ;;
        0) sair_menu_proxy ;;
        *) echo -e "\033[1;31mOpção inválida. Por favor, tente novamente.\033[0m" ; pausa_prompt ;;
    esac

    principal
}

principal
