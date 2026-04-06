#!/bin/bash

# --- TEST SCRIPT FOR DIONAEA HONEYPOT (10.0.10.20) ---

echo "--- STEP 1: Verifying Dionaea Container Status ---"
docker ps --filter "name=inet-honeypot-dionaea" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n--- STEP 2: Running Port Scan from External Client (inet-client-01) ---"
# Nmap scanning common Dionaea ports (21, 42, 80, 443, 445, 1433, 3306)
docker exec inet-client-01 nmap -Pn -p 21,42,80,443,445,1433,3306 10.0.10.20

echo -e "\n--- STEP 3: Attempting Simple HTTP Connection (Port 80) ---"
docker exec inet-client-01 curl -I -s --connect-timeout 2 http://10.0.10.20 || echo "Curl failed (expected if Dionaea doesn't return headers, but log check will verify if seen)"

echo -e "\n--- STEP 4: Checking Dionaea Logs for Recent Activity ---"
docker exec inet-honeypot-dionaea tail -n 20 /opt/dionaea/var/log/dionaea/dionaea.log
