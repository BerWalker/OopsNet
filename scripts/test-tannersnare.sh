#!/bin/bash
# scripts/test-tannersnare.sh
# Comprehensive test for Tanner/Snare honeypot framework

# Terminal colors
BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== TANNER/SNARE HONEYPOT TEST ===${NC}"

# Configuration
FW_EXT_IP="10.0.10.254"
SNARE_IP="10.0.20.22"
TANNER_IP="10.0.20.21"
CLIENT="inet-client-01"

echo -e "\n${YELLOW}1. Testing Snare Accessibility from Internet...${NC}"
# Use wget since it was available in previous turns, or curl if I installed it
# inet-client-01 has nmap and nikto, and I saw wget working.
HTTP_STATUS=$(docker exec "$CLIENT" wget --spider --quiet --server-response http://$FW_EXT_IP:8080 2>&1 | grep "HTTP/" | awk '{print $2}')

if [[ "$HTTP_STATUS" == "200" ]]; then
    echo -e "  [${GREEN}OK${NC}] Snare is reachable via Firewall (Port 8080)"
else
    echo -e "  [${RED}FAIL${NC}] Snare unreachable or returned error: $HTTP_STATUS"
fi

echo -e "\n${YELLOW}2. Testing Snare -> Tanner Connectivity...${NC}"
# Use curl to check the Tanner API port (8090)
# -s (silent), -f (fail), -o /dev/null (hide output)
docker exec dmz-snare-01 curl -s -o /dev/null http://$TANNER_IP:8090
if [ $? -ne 7 ]; then # Connection refused is 7. If it's 200 or 404 or something, it's alive.
    echo -e "  [${GREEN}OK${NC}] Snare can reach Tanner API (Port 8090)"
else
    echo -e "  [${RED}FAIL${NC}] Snare cannot reach Tanner API on $TANNER_IP:8090"
fi

echo -e "\n${YELLOW}3. Testing End-to-End Honeypot Engagement...${NC}"
echo "  Simulating an SQLi attack request to Snare..."
ATTACK_PATH="/index.php?id='OR+1=1--"
ATTACK_URL="http://$FW_EXT_IP:8080$ATTACK_PATH"
docker exec "$CLIENT" wget -q -O /dev/null "$ATTACK_URL"

echo "  Waiting for Tanner to process event..."
sleep 2

# Check Tanner logs for the pattern: 'Requested path' and 'sqli'
LOG_MATCH=$(docker exec dmz-tanner-01 grep -E "Requested path|sqli" /opt/tanner/tanner.log 2>/dev/null | tail -n 5)

if [ ! -z "$LOG_MATCH" ]; then
    echo -e "  [${GREEN}OK${NC}] Tanner recorded and analyzed the attack!"
    echo -e "  Log insight:\n${BLUE}$LOG_MATCH${NC}"
else
    echo -e "  [${RED}FAIL${NC}] No attack event found in Tanner logs."
    echo "  Checking log file status:"
    docker exec dmz-tanner-01 ls -l /opt/tanner/tanner.log
fi

echo -e "\n${BLUE}=== TEST COMPLETE ===${NC}"
