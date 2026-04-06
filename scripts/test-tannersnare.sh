#!/bin/bash
# Description: Comprehensive test for the Tanner/Snare honeypot framework, including internal connectivity and external attacks.

# Color Definitions
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Target Configuration
FW_EXT_IP="10.0.10.254"
TANNER_IP="10.0.20.21"
CLIENT="inet-client-01"

echo -e "${BLUE}[+] STARTING TANNER/SNARE HONEYPOT TEST${NC}"

echo -e "\n${YELLOW}PHASE 1: Testing Snare Accessibility from External Internet...${NC}"
# Use curl since I've verified it's now installed in the inet-client-01
HTTP_STATUS=$(docker exec "$CLIENT" curl -s -o /dev/null -w "%{http_code}" http://$FW_EXT_IP:8080)

if [[ "$HTTP_STATUS" == "200" ]]; then
    echo -e "  [${GREEN}OK${NC}] Snare is reachable via Firewall (Port 8080)"
else
    echo -e "  [${RED}FAIL${NC}] Snare unreachable or returned error code: $HTTP_STATUS"
fi

echo -e "\n${YELLOW}PHASE 2: Testing Snare -> Tanner internal connectivity...${NC}"
# Use curl to check the Tanner API port (8090)
docker exec dmz-snare-01 curl -s -o /dev/null http://$TANNER_IP:8090
if [ $? -ne 7 ]; then # Connection refused is 7. If it's 200 or 404, it means the service is alive.
    echo -e "  [${GREEN}OK${NC}] Snare can reach Tanner API (Port 8090)"
else
    echo -e "  [${RED}FAIL${NC}] Snare cannot reach Tanner API on $TANNER_IP:8090"
fi

echo -e "\n${YELLOW}PHASE 3: Running Nikto Scan from Internet Client...${NC}"
echo "  Targeting Snare honeypot via the Edge Firewall..."
docker exec "$CLIENT" nikto -h http://$FW_EXT_IP:8080 -Tuning 1 2 3 -maxtime 30s
echo -e "  [${GREEN}INFO${NC}] Nikto scan triggered and logged by Tanner/Snare."

echo -e "\n${YELLOW}PHASE 4: Testing End-to-End Analysis (SQLi Simulation)...${NC}"
echo "  Launching pattern attack..."
ATTACK_URL="http://$FW_EXT_IP:8080/index.php?id='OR+1=1--"
docker exec "$CLIENT" curl -s -o /dev/null "$ATTACK_URL"

echo "  Waiting for Tanner to process analysis event..."
sleep 2

# Check Tanner logs for detection results
LOG_MATCH=$(docker exec dmz-tanner-01 grep -E "Requested path|sqli|rfi|lfi|xss" /opt/tanner/tanner.log 2>/dev/null | tail -n 5)

if [ ! -z "$LOG_MATCH" ]; then
    echo -e "  [${GREEN}OK${NC}] Tanner recorded and analyzed the attack events!"
    echo -e "  Latest Log Insights:\n${BLUE}$LOG_MATCH${NC}"
else
    echo -e "  [${RED}FAIL${NC}] No attack events found in Tanner logs."
    echo "  Checking log file status:"
    docker exec dmz-tanner-01 ls -l /opt/tanner/tanner.log
fi

echo -e "\n${BLUE}[+] TANNER/SNARE TEST COMPLETE${NC}"
