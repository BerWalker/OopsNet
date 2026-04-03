# OopsNet — Honeypot Project

OopsNet is a specialized network simulation environment designed as a robust foundation for cybersecurity research and honeypot deployment. The project emphasizes a **multi-tiered defense-in-depth architecture**, isolating services across strictly controlled Docker subnets.

## Core Architecture Overview

The infrastructure simulates a professional enterprise environment with segmented security zones and dual-firewall enforcement:

```mermaid
graph TD
    inet("Internet / WAN")

    hp_perim("⚠️ honeypot — perimeter")
    ext_fw("fw-edge-01<br>allowed: 80")
    
    inet -.-> hp_perim
    inet --> ext_fw

    subgraph DMZ ["DMZ — 10.0.20.0/24"]
        web("dmz-webserver-01<br>Next.js · 10.0.20.10 · :80")
        mail("mail-server")
        hp_dmz("⚠️ honeypot — DMZ")
    end

    ext_fw --> DMZ

    int_fw("fw-internal-01<br>allowed: 5432")
    
    DMZ --> int_fw

    subgraph Internal ["Internal network — 10.0.30.0/24 · isolated"]
        ws("workstation")
        
        erp("erp-system")
        smb("fileshare")
        db("int-database-01<br>PostgreSQL 14 · 10.0.30.10 · :5432")
        hp_int("⚠️ honeypot — internal")

        subgraph wazuh_zone ["Wazuh SIEM"]
            direction LR
            w_mgr("wazuh-manager")
            w_idx("wazuh-indexer")
            w_dash("wazuh-dashboard")
            w_mgr -.-> w_idx
            w_idx -.-> w_dash
        end
        
        ws --> erp
        ws -.-> smb
        ws -.-> w_mgr
        erp -.-> db
    end

    int_fw --> Internal
```

### 1. External Zone (10.0.10.x)
Represents the untrusted public internet. All traffic originating from here is strictly filtered by the Edge Firewall before reaching any services.

### 2. Edge Firewall & DMZ (10.0.20.x)
The **Edge Firewall (`fw-edge-01`)** acts as the primary gateway. It utilizes `iptables` to strictly permit only HTTP (Port 80) traffic into the DMZ.
- **NAT Redirection**: Traffic hitting the host on port 8000 is NAT-forwarded through the Edge Firewall directly to the Web Server.
- **Isolation**: Services in the DMZ cannot bypass the internal firewall to reach protected assets directly.

### 3. Internal Firewall & Private Network (10.0.30.x)
The **Internal Firewall (`fw-internal-01`)** represents the second line of defense. It enforces a "Default Drop" policy, only permitting the Web Server to communicate with the database via port 5432 (PostgreSQL).
- **Hardened Routing**: The internal network is unreachable from the external zone.
- **Simulation Target**: This zone holds the sensitive data that future honeypots will be designed to protect or simulate.

## Infrastructure Automation

The environment is managed via automated shell scripts to ensure consistent state and security validation:

- **`run.sh`**: The master deployment script. It triggers a deep cleanup followed by a full stack re-orchestration.
- **`scripts/cleanup-docker.sh`**: Performs an absolute flush of the Docker engine (containers, networks, and volumes) to prevent any configuration drift.
- **`scripts/network_check-docker.sh`**: An automated **Security Audit** script that runs immediately after deployment. It attempts various unauthorized access vectors to confirm that the dual-firewall topology is functioning correctly.

## Quick Start

Ensure you have **Docker** and **Docker Compose** installed.

```bash
# Copy example environment file to active .env
cp .env.example .env

# Set execute permissions
chmod +x run.sh scripts/*.sh

# Initialize the global infrastructure and run security audit
./run.sh
```

- **Access Point**: The DMZ WebApp (simulated service) is reachable at `http://localhost:8000`.

## Future Roadmap
This infrastructure serves as the baseline for the upcoming implementation of **Honeypots** (Dionaea, Cowrie, etc.). The existing WebApp and Database are currently used as the "target" or "bait" services to evaluate the efficiency of the perimeter defense before introducing advanced detection nodes.

---
*Disclaimer: This is a simulated environment intended for cybersecurity research and demonstration purposes.*
