# 🛡️ Enterprise Cybersecurity & Systems Infrastructure Portfolio

Hands-on IT operations, systems administration, and security engineering infrastructure built and validated within a dedicated home lab. Each deployment simulates enterprise-grade networks, attack vectors, and defensive engineering workflows—fully documented with telemetry evidence, root-cause findings, and measurable remediation results.

**Target Roles:** IT Help Desk Representative · Junior System Administrator · SOC Analyst (Tier 1)
**Professional Objectives:** CompTIA Security+ (SY0-701) 📚 · TryHackMe Cyber Security 101 Path 🔄
**Location:** Jacksonville, NC

---

## 🎯 Professional Overview

I build, break, monitor, and harden systems to bridge the gap between foundational IT infrastructure and defensive security operations. Rather than following static tutorials, I focus on analyzing system telemetry, identifying visibility gaps, and engineering reproducible technical solutions.

---

## 🖥️ Operational Environments

### Lab Infrastructure v2 (Active Workstation)
*   **Host Workstation:** AMD Ryzen AI 7 350 | 32GB DDR5 RAM | 1TB NVMe Storage
*   **Hypervisor Engine:** Oracle VirtualBox
*   **Security Boundary:** OPNsense Virtual Firewall Appliance
*   **Network Topology:** Isolated Host-Only and Segmented Internal LANs (Air-gapped from production home network)

### Lab Infrastructure v1 (Legacy Testing)
*   **Resource Constraints:** Single 8GB RAM Workstation (Built via single-VM sequential provisioning workflows)

### ⚠️ Operational Risk Mitigation Rules
1.  **Network Isolation:** All aggressive traffic and attack simulations are strictly contained within virtual internal networks (`LabNetwork`).
2.  **Host Integrity:** Host-level Endpoint Detection and Response (EDR) and Windows Defender configurations remain active at all times.
3.  **State Recovery:** Snapshots and configuration backups are generated before any destructive testing or major version updates.

---

## 📊 Engineering & Analytical Highlights

*   **Connected Incident Reconstruction:** Reconstructed a complete account-takeover timeline within Splunk, tracking a critical Sunday-morning credential anomaly (Lab 5) back to the explicit spear-phishing attack vector and weaponized links that initiated the compromise (Lab 6).
*   **Vulnerability Remediation Velocity:** Executed credentialed Nessus infrastructure assessments against a domain controller, moving the security posture from **1 Critical and 7+ High findings to a verified state of 0 vulnerabilities** through aggressive patch management and configuration hardening (Lab 7).
*   **Telemetry Visibility Audit:** Identified and resolved significant visibility gaps where failed domain authentication requests bypassed logging mechanisms (Lab 5), and diagnosed an Ubuntu `sudo-rs` logging omission that silently dropped denied privilege escalation events (Lab 8).
*   **Defensive Boundary Engineering:** Engineered an isolated enterprise local area network (LAN) behind a custom-configured OPNsense firewall, enforcing strict egress filtering rules so lab endpoints can access the external WAN exclusively through the secure proxy (Lab 10).

---

## 📂 Active Engineering Labs

| # | Enterprise Lab Project | Applied Engineering Skills | Operational Status |
| :--- | :--- | :--- | :--- |
| **01** | [Enterprise osTicket Lifecycle Management](./labs/01-helpdesk-ticket-system/) | SLA Configuration, Apache, MariaDB, PHP, Triage | 🟢 Completed & Documented |
| **02** | [Active Directory & Domain Infrastructure](./labs/02-active-directory-domain/) | Windows Server 2025, GPO, Event ID 4740 Isolation | 🟢 Completed & Documented |
| **03** | [Windows Security Monitoring & Endpoint Threat Hunting](./labs/03-windows-security-monitoring/) | Sysmon, PowerShell Threat Hunting, Log Correlation | 🟢 Completed & Documented |
| **04** | [Centralized Log Aggregation via Cloud SIEM](./labs/04-cloud-siem-splunk/) | Splunk Cloud, Universal Forwarder, Baseline Dashboards | 🟢 Completed & Documented |
| **05** | [Identity Anomaly & Kerberos Audit Triage](./labs/05-suspicious-login-investigation/) | Timeline Reconstruction, Audit Policy Fine-Tuning | 🟢 Completed & Documented |
| **06** | [Malicious Email & Spear-Phishing Ingestion Analysis](./labs/06-phishing-email-analysis/) | SPF/DKIM/DMARC Spoof Auditing, IOC Extraction | 🟢 Completed & Documented |
| **07** | [Vulnerability Lifecycle & Surface Area Remediation](./labs/07-vulnerability-scanning-nessus/) | Nessus Essentials, CVSS Priority Patching, Verification | 🟢 Completed & Documented |
| **08** | [Linux Host Hardening & Telemetry Engineering](./labs/08-linux-security-monitoring/) | Ubuntu Server 26.04 LTS, SSH Key Enforcement, systemd | 🟢 Completed & Documented |
| **09** | [Infrastructure Design: Enterprise Lab Architecture v2](./labs/09-home-lab-v2-architecture/) | Capacity Planning, Resource Allocation, Topology Design | 🟢 Completed & Documented |
| **10** | [Network Segmentation & Egress Firewall Controls](./labs/10-opnsense-firewall-network/) | OPNsense, Stateful Inspection, DHCP, Routing Rules | 🟢 Completed & Documented |

> **Note:** Every lab directory maintains a dedicated standalone documentation suite mapping precisely to: **Objective ➔ Setup & Topology ➔ Evidence ➔ Investigation ➔ Root-Cause Analysis ➔ Resolution ➔ Lessons Learned**, reinforced with embedded configuration screenshots and log block syntax.

---

## 🧰 Technical Competency Framework

### Systems & Network Administration
*   **Operating Systems:** Windows Server 2025, Windows 11 Enterprise, Ubuntu Server 26.04 LTS, Kali Linux
*   **Directory Services:** Active Directory Domain Services (AD DS), Organizational Unit (OU) Architecture, Group Policy Object (GPO) Security Baselines
*   **Core Networking:** Stateful Packet Inspection (SPI) Firewalls, DHCP Scopes, Static Routing, DNS Resolution, APIPA/Subnet Troubleshooting, SSH Hardening

### Security Operations & Defenses
*   **SIEM & Analytics:** Splunk Cloud, Splunk Enterprise, Splunk Search Processing Language (SPL) Dashboard Engineering
*   **Endpoint Telemetry:** Microsoft Sysmon Deployment, Windows Security Event Log Analysis (Event IDs 4625, 4740, 4720, 4728, 4104, 4698)
*   **Vulnerability Management:** Credentialed Network Auditing, CVSS/EPSS Threat Prioritization, Patch Verification
*   **Defensive Investigation:** Email Header Analysis, Open-Source Intelligence (OSINT), Indicator of Compromise (IOC) Analysis

---

## 📂 Repository Workspace Blueprint

```text
cybersecurity-labs/
├── README.md            <-- Primary Portfolio Hub & Technical Profile
├── detections/          <-- Production Splunk SPL Queries & PowerShell Triage Automation Scripts
└── labs/
    ├── 01-helpdesk-ticket-system/
    ├── ...
    └── 10-opnsense-firewall-network/
```

---

## 📫 Professional Contact

*   **GitHub Main Workspace:** [jaydenambrose5-beep](https://github.com)
*   **LinkedIn Professional Profile:** *[Insert Your Custom LinkedIn URL Here]*

---
*Disclaimer: All engineering, testing, and security analysis documented within this workspace were executed within a strictly managed, non-production, air-gapped lab framework solely for educational and research purposes.*
