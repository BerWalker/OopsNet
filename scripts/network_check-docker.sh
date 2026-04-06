#!/bin/bash
# Terminal colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}--- SECURITY AUDIT: DOUBLE FIREWALL ---${NC}"

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

echo -e "\n${YELLOW}1. EXTERNAL ZONE (Internet) -> DMZ${NC}"
check_port "inet-client-01" "10.0.20.10" "80" "true" "Web Access Allowed"
check_port "inet-client-01" "10.0.20.10" "22" "false" "SSH Attempt (Forbidden)"
check_port "inet-client-01" "10.0.20.10" "443" "false" "HTTPS Attempt (Not configured)"

echo -e "\n${YELLOW}2. EXTERNAL ZONE (Internet) -> INTERNAL NETWORK${NC}"
check_port "inet-client-01" "10.0.30.10" "5432" "false" "Direct jump to Database"
check_port "inet-client-01" "10.0.30.10" "80" "false" "Direct jump to Internal"

echo -e "\n${YELLOW}3. DMZ ZONE -> INTERNAL NETWORK${NC}"
check_port "dmz-webserver-01" "10.0.30.10" "5432" "true" "Database Connection Allowed"
check_port "dmz-webserver-01" "10.0.30.10" "22" "false" "Internal SSH Attempt (Forbidden)"
check_port "dmz-webserver-01" "10.0.30.10" "80" "false" "Internal HTTP Attempt (Forbidden)"

echo -e "\n${YELLOW}4. ICMP TEST (PING)${NC}"
echo -n "  Ping Internet -> DMZ: "
sudo docker exec inet-client-01 ping -c 1 -W 1 10.0.20.10 > /dev/null 2>&1
if [ $? -ne 0 ]; then echo -e "${GREEN}BLOCKED (Correct)${NC}"; else echo -e "${RED}ALLOWED (Incorrect)${NC}"; fi

echo -e "\n${BLUE}--- END OF AUDIT ---${NC}"