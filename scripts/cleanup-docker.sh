#!/bin/bash
# Description: Scoped cleanup for OopsNet project only, avoiding interference with other Docker containers.

# Color Definitions
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}[+] STARTING PROJECT CLEANUP (OopsNet ONLY)${NC}"

# Using docker compose to shutdown only current project resources
# -v removes volumes (persistent data)
# --remove-orphans cleans up containers not in the current compose file
if [ -f "compose.yaml" ]; then
    echo -e "${BLUE}[+] STEP 1: Shutting down project containers and removing volumes...${NC}"
    docker compose down -v --remove-orphans
else
    echo -e "  [${RED}ERROR${NC}] compose.yaml not found in current directory!"
    exit 1
fi

echo -e "\n${RED}[OK] PROJECT RESOURCES WIPED SUCCESSFULLY${NC}"