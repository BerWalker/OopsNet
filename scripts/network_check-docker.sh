#!/bin/bash
# Cores para o terminal
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}--- AUDITORIA DE SEGURANÇA: DOUBLE FIREWALL ---${NC}"

check_port() {
    local origin=$1
    local target=$2
    local port=$3
    local expected=$4
    local desc=$5

    sudo docker exec "$origin" nc -zv -w 2 "$target" "$port" > /dev/null 2>&1
    local status=$?

    if [ "$expected" = "true" ]; then
        if [ $status -eq 0 ]; then
            echo -e "  [${GREEN}OK${NC}] $desc (Porta $port): LIBERADO"
        else
            echo -e "  [${RED}FALHA${NC}] $desc (Porta $port): BLOQUEADO INDEVIDAMENTE"
        fi
    else
        if [ $status -ne 0 ]; then
            echo -e "  [${GREEN}OK${NC}] $desc (Porta $port): BLOQUEADO"
        else
            echo -e "  [${RED}ALERTA${NC}] $desc (Porta $port): VULNERÁVEL (Aberto!)"
        fi
    fi
}

echo -e "\n${YELLOW}1. ZONA EXTERNA (Internet) -> DMZ${NC}"
check_port "inet-client-01" "10.0.20.10" "80" "true" "Acesso Web Permitido"
check_port "inet-client-01" "10.0.20.10" "22" "false" "Tentativa SSH (Proibido)"
check_port "inet-client-01" "10.0.20.10" "443" "false" "Tentativa HTTPS (Não configurado)"

echo -e "\n${YELLOW}2. ZONA EXTERNA (Internet) -> REDE INTERNA${NC}"
check_port "inet-client-01" "10.0.30.10" "5432" "false" "Salto direto p/ Banco"
check_port "inet-client-01" "10.0.30.10" "80" "false" "Salto direto p/ Interna"

echo -e "\n${YELLOW}3. ZONA DMZ -> REDE INTERNA${NC}"
check_port "dmz-webserver-01" "10.0.30.10" "5432" "true" "Conexão de Banco Permitida"
check_port "dmz-webserver-01" "10.0.30.10" "22" "false" "Tentativa SSH Interno (Proibido)"
check_port "dmz-webserver-01" "10.0.30.10" "80" "false" "Tentativa HTTP Interno (Proibido)"

echo -e "\n${YELLOW}4. TESTE DE ICMP (PING)${NC}"
echo -n "  Ping Internet -> DMZ: "
sudo docker exec inet-client-01 ping -c 1 -W 1 10.0.20.10 > /dev/null 2>&1
if [ $? -ne 0 ]; then echo -e "${GREEN}BLOQUEADO (Correto)${NC}"; else echo -e "${RED}LIBERADO (Incorreto)${NC}"; fi

echo -e "\n${BLUE}--- FIM DA AUDITORIA ---${NC}"