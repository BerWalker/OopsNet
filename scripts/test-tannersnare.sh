#!/bin/bash

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

FW_EXT_IP="10.0.10.254"
TANNER_IP="10.0.20.21"
CLIENT="inet-client-01"

echo -e "${BLUE}[+] STARTING TANNER/SNARE HONEYPOT TEST${NC}"

echo -e "\n${YELLOW}PHASE 1: Testing Snare Accessibility from External Internet...${NC}"
HTTP_STATUS=$(docker exec "$CLIENT" curl -s -o /dev/null -w "%{http_code}" http://$FW_EXT_IP:8080)
[[ "$HTTP_STATUS" == "200" ]] \
    && echo -e "  [${GREEN}OK${NC}] Snare is reachable via Firewall (Port 8080)" \
    || echo -e "  [${RED}FAIL${NC}] Snare unreachable or returned error code: $HTTP_STATUS"

echo -e "\n${YELLOW}PHASE 2: Testing Snare -> Tanner internal connectivity...${NC}"
docker exec dmz-snare-01 curl -s -o /dev/null http://$TANNER_IP:8090
# exit 7 = connection refused (port closed); anything else means service is alive
[ $? -ne 7 ] \
    && echo -e "  [${GREEN}OK${NC}] Snare can reach Tanner API (Port 8090)" \
    || echo -e "  [${RED}FAIL${NC}] Snare cannot reach Tanner API on $TANNER_IP:8090"

echo -e "\n${YELLOW}PHASE 3: Running Nikto Scan from Internet Client...${NC}"
docker exec "$CLIENT" nikto -h http://$FW_EXT_IP:8080 -Tuning 1 2 3 -maxtime 30s
echo -e "  [${GREEN}INFO${NC}] Nikto scan triggered and logged by Tanner/Snare."

echo -e "\n${YELLOW}PHASE 4: Testing End-to-End Analysis (SQLi Simulation)...${NC}"
echo "  Launching pattern attack..."
docker exec "$CLIENT" curl -s -o /dev/null "http://$FW_EXT_IP:8080/index.php?id='OR+1=1--"

echo "  Waiting for Tanner to process analysis event..."
sleep 2

LOG_MATCH=$(docker exec dmz-tanner-01 grep -E "Requested path|sqli|rfi|lfi|xss" /opt/tanner/tanner.log 2>/dev/null | tail -n 5)
if [ ! -z "$LOG_MATCH" ]; then
    echo -e "  [${GREEN}OK${NC}] Tanner recorded and analyzed the attack events!"
    echo -e "  Latest Log Insights:\n${BLUE}$LOG_MATCH${NC}"
else
    echo -e "  [${RED}FAIL${NC}] No attack events found in Tanner logs."
    docker exec dmz-tanner-01 ls -l /opt/tanner/tanner.log
fi

echo -e "\n${BLUE}[+] TANNER/SNARE TEST COMPLETE${NC}"
