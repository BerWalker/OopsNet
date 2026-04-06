#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[+] STARTING PROJECT CLEANUP (OopsNet ONLY)${NC}"

if [ -f "compose.yaml" ]; then
    echo -e "${BLUE}[+] STEP 1: Shutting down project containers and removing volumes...${NC}"
    docker compose down -v --remove-orphans
else
    echo -e "  [${RED}ERROR${NC}] compose.yaml not found!"
    exit 1
fi

echo -e "\n${BLUE}[+] STEP 2: Removing shared log directories...${NC}"
sudo rm -rf ./logs


echo -e "\n${RED}[OK] PROJECT RESOURCES WIPED SUCCESSFULLY${NC}"