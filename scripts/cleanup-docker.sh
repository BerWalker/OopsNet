#!/bin/bash

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}--- STARTING TOTAL DOCKER CLEANUP ---${NC}"

echo -e "${BLUE}Stopping all containers...${NC}"
sudo docker stop $(sudo docker ps -aq) 2>/dev/null

echo -e "${BLUE}Removing all containers...${NC}"
sudo docker rm -f $(sudo docker ps -aq) 2>/dev/null

# (Docker does not remove default networks: bridge, host, none)
echo -e "${BLUE}Removing all networks...${NC}"
sudo docker network prune -f
sudo docker network rm $(sudo docker network ls -q) 2>/dev/null

echo -e "${BLUE}Removing all volumes (Persistent data)...${NC}"
sudo docker volume rm $(sudo docker volume ls -q) 2>/dev/null
sudo docker volume prune -f

echo -e "${BLUE}Removing all images...${NC}"
sudo docker rmi -f $(sudo docker images -aq) 2>/dev/null

echo -e "${BLUE}Cleaning build cache and residual objects...${NC}"
sudo docker system prune -a --volumes -f

echo -e "${RED}--- ALL DATA WIPED SUCCESSFULLY ---${NC}"