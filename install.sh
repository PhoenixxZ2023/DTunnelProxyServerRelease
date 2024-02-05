#!/bin/bash

sudo rm -f /usr/bin/main /usr/bin/proxy
sudo curl -sL -o /usr/bin/main https://github.com/DTunnel0/DTunnelProxyServerRelease/raw/main/main.sh
sudo curl -sL -o /usr/bin/proxy https://github.com/DTunnel0/DTunnelProxyServerRelease/raw/main/build/$(uname -m)/proxy
sudo chmod +x /usr/bin/main /usr/bin/proxy
clear && echo -e "\033[1;31mExecute: \033[1;32mmain\033[0m"
