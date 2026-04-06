#!/bin/bash
# Description: Validates Kippo honeypot functionality by simulating an SSH login and checking the database records.

# Color Definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Target Configuration
KIPPO_IP="10.0.30.20"
FW_INTERNAL="fw-internal-01"
KIPPO_CONTAINER="int-honeypot-01"

echo -e "${BLUE}[+] STARTING KIPPO HONEYPOT TEST${NC}"

echo -e "\n${BLUE}[+] STEP 1: Verifying Kippo container status...${NC}"
docker ps --filter "name=${KIPPO_CONTAINER}" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n${BLUE}[+] STEP 2: Installing SSH client in Internal Firewall (${FW_INTERNAL})...${NC}"
docker exec -it ${FW_INTERNAL} apk add --no-cache openssh-client

echo -e "\n${BLUE}[+] STEP 3: Attempting SSH connection to Kippo Honeypot (${KIPPO_IP})...${NC}"
echo -e "  Note: Use password '123456' if prompted."
docker exec -it ${FW_INTERNAL} ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa -o Ciphers=+aes128-cbc -o StrictHostKeyChecking=no root@${KIPPO_IP}

echo -e "\n${BLUE}[+] STEP 4: Checking Kippo logs for your session...${NC}"
docker exec -it ${KIPPO_CONTAINER} tail -n 20 /home/kippo/kippo/log/kippo.log

echo -e "\n${BLUE}[+] STEP 5: Viewing last login record in Kippo database...${NC}"
docker exec -it ${KIPPO_CONTAINER} cat /home/kippo/kippo/data/lastlog.txt

echo -e "\n${BLUE}[OK] KIPPO TEST COMPLETE${NC}"