echo "--- STEP 0: Installing SSH client in fw-internal-01 ---"
docker exec -it fw-internal-01 apk add openssh-client

echo "--- STEP 1: Attempting SSH connection to Kippo Honeypot (10.0.30.20) ---"
echo "Note: Use password '123456' if prompted."
docker exec -it fw-internal-01 ssh -o KexAlgorithms=+diffie-hellman-group1-sha1 -o HostKeyAlgorithms=+ssh-rsa -o Ciphers=+aes128-cbc -o StrictHostKeyChecking=no root@10.0.30.20

echo -e "\n--- STEP 2: Checking Kippo logs for your session ---"
docker exec -it int-honeypot-01 cat log/kippo.log | tail -n 20

echo -e "\n--- STEP 3: Viewing last login record in Kippo DB ---"
docker exec -it int-honeypot-01 cat /home/kippo/kippo/data/lastlog.txt