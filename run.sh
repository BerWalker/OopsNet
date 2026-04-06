#!/bin/bash
# ==============================================================================
# Script: run.sh
# Purpose: Main entrypoint for launching and auditing the OopsNet infrastructure.
# Controls: Docker Compose, Network Audits, and Cleanup.
# ==============================================================================

set -e

# Color Definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== STARTING OOPSNET INFRASTRUCTURE ===${NC}"

# Check for Docker login if needed, or handle it gracefully
echo -e "\n${YELLOW}[+] STEP 1: Performing Pre-check Cleanup...${NC}"
./scripts/cleanup-docker.sh

# Checking if docker-compose file is valid
echo -e "\n${YELLOW}[+] STEP 2: Validating Infrastructure Configuration...${NC}"
docker compose config -q || { echo -e "  [${RED}ERROR${NC}] Docker Compose validation failed!"; exit 1; }

# Starting the containers
echo -e "\n${YELLOW}[+] STEP 3: Building and Starting Services in DMZ and Internal Net...${NC}"
docker compose up -d

# Giving a small delay for services to initialize
echo -e "\n${YELLOW}[+] STEP 4: Services initializing (Waiting 5s)...${NC}"
sleep 5

# Running the network audit
echo -e "\n${YELLOW}[+] STEP 5: Running Automated Security Audit...${NC}"
./scripts/network_check-docker.sh

echo -e "\n${GREEN}=== ALL PROCESSES COMPLETED SUCCESSFULLY ===${NC}"
echo -e "${BLUE}Project is active and analyzed. You can run honeypot-specific tests now.${NC}"
echo -e "  ./scripts/test-dionaea.sh"
echo -e "  ./scripts/test-tannersnare.sh"
echo -e "  ./scripts/test-kippo.sh"