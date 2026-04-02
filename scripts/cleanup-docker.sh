#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- INICIANDO LIMPEZA ABSOLUTA DO DOCKER ---${NC}"

echo -e "${BLUE}Parando todos os containers...${NC}"
sudo docker stop $(sudo docker ps -aq) 2>/dev/null

echo -e "${BLUE}Removendo todos os containers...${NC}"
sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null

# (O Docker não remove as redes padrão: bridge, host, none)
echo -e "${BLUE}Removendo todas as redes...${NC}"
sudo docker network prune -f
sudo docker network rm $(sudo docker network ls -q) 2>/dev/null

echo -e "${BLUE}Removendo todos os volumes (Dados persistentes)...${NC}"
sudo docker volume rm $(sudo docker volume ls -q) 2>/dev/null
sudo docker volume prune -f

echo -e "${BLUE}Removendo todas as imagens...${NC}"
sudo docker rmi -f $(sudo docker images -aq) 2>/dev/null

echo -e "${BLUE}Limpando cache de build e objetos residuais...${NC}"
sudo docker system prune -a --volumes -f

echo -e "${RED}--- TUDO FOI APAGADO COM SUCESSO ---${NC}"