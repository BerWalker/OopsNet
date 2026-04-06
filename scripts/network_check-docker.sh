#!/bin/bash
# Description: Automated security audit for validating firewall rules and zone isolation.

# Color Definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check Function
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
            echo -e "  [${GREEN}OK${NC}] $desc (Port $port): ALLOWED"
        else
            echo -e "  [${RED}FAILURE${NC}] $desc (Port $port): IMPROPERLY BLOCKED"
        fi
    else
        if [ $status -ne 0 ]; then
            echo -e "  [${GREEN}OK${NC}] $desc (Port $port): BLOCKED"
        else
            echo -e "  [${RED}ALERT${NC}] $desc (Port $port): VULNERABLE (Open!)"
        fi
    fi
}

echo -e "${BLUE}[+] STARTING SECURITY AUDIT: DOUBLE FIREWALL${NC}"

echo -e "\n${YELLOW}PHASE 1: EXTERNAL ZONE (Internet) -> DMZ${NC}"
check_port "inet-client-01" "10.0.20.10" "80" "true" "Web Access Allowed"
check_port "inet-client-01" "10.0.20.10" "22" "false" "SSH Attempt (Forbidden)"
check_port "inet-client-01" "10.0.20.10" "443" "false" "HTTPS Attempt (Not configured)"

echo -e "\n${YELLOW}PHASE 2: EXTERNAL ZONE (Internet) -> INTERNAL NETWORK${NC}"
check_port "inet-client-01" "10.0.30.10" "5432" "false" "Direct jump to Database"
check_port "inet-client-01" "10.0.30.10" "80" "false" "Direct jump to Internal"

echo -e "\n${YELLOW}PHASE 3: DMZ ZONE -> INTERNAL NETWORK${NC}"
check_port "dmz-webserver-01" "10.0.30.10" "5432" "true" "Database Connection Allowed"
check_port "dmz-webserver-01" "10.0.30.10" "22" "false" "Internal SSH Attempt (Forbidden)"
check_port "dmz-webserver-01" "10.0.30.10" "80" "false" "Internal HTTP Attempt (Forbidden)"

echo -e "\n${YELLOW}PHASE 4: HONEYPOT AUDIT (Kippo)${NC}"
check_port "fw-internal-01" "10.0.30.20" "22" "true" "Internal Access to Honeypot"
check_port "inet-client-01" "10.0.30.20" "22" "false" "External Access to Internal Honeypot"

echo -e "\n${YELLOW}PHASE 5: HONEYPOT AUDIT (Tanner/Snare - DMZ)${NC}"
check_port "inet-client-01" "10.0.10.254" "8080" "true" "Internet -> Snare Web Honeypot (via FW)"
check_port "inet-client-01" "10.0.20.21" "8090" "false" "Internet -> Tanner Backend (Forbidden)"
check_port "dmz-snare-01" "10.0.20.21" "8090" "true" "Snare -> Tanner API (Analysis Link)"

echo -e "\n${YELLOW}PHASE 6: ICMP TEST (PING)${NC}"
echo -n "  Ping Internet -> DMZ: "
sudo docker exec inet-client-01 ping -c 1 -W 1 10.0.20.10 > /dev/null 2>&1
if [ $? -ne 0 ]; then echo -e "${GREEN}BLOCKED (Correct)${NC}"; else echo -e "${RED}ALLOWED (Incorrect)${NC}"; fi

echo -e "\n${BLUE}[+] END OF AUDIT: ALL RULES TESTED${NC}"