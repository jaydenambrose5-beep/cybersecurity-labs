# 🔍 Detection Engineering & Incident Triage Queries

This directory contains production-ready security monitoring queries, event correlation logic, and automated triage scripts developed and validated within my virtual enterprise environment. These artifacts demonstrate hands-on competency in log analysis, signature development, and threat hunting workflows.

---

## 🛠️ Splunk Search Processing Language (SPL) Queries

### 🚨 Kerberos Audit Policy Gap Discovery (Lab 5 Reference)
*   **Objective:** Identifies missing audit configurations where successful/failed authentication events fail to write to the local security log.
*   **Query:**
```spl
index=security EventCode=4720 OR EventCode=4722 OR EventCode=4725
| table _time, host, user, EventCode, Message
| sort - _time
```

### 🔒 SSH Brute Force Triage (Lab 8 Reference)
*   **Objective:** Monitors Linux system authentication logs (`/var/log/auth.log`) to aggregate and flag high-volume malicious authentication anomalies targeting public-facing infrastructure.
*   **Query:**
```spl
index=linux sourcetype=syslog "Failed password for"
| stats count by src_ip, user
| where count > 10
| sort - count
```

---

## 💻 PowerShell Triage Automation Scripts

### 🕒 Live Incident Artifact Gathering (`Triage-Collector.ps1`)
*   **Objective:** Automates local system live-response workflows to pull high-fidelity process telemetry, network connection states, and active persistence mechanisms during an investigation.
*   **Script Framework:**
```powershell
# Get Active Network Connections and associated Processes
Get-NetTCPConnection -State Established | Select-Object LocalAddress, LocalPort, RemoteAddress, RemotePort, OwningProcess

# Check Common Persistence Run Keys
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Run
```

---

## 📊 Deployment & Validation Workflow
1. Log telemetry is securely aggregated via localized heavy forwarders or Universal Forwarders.
2. Raw data flows into dedicated index boundaries (`index=security` or `index=linux`).
3. Search queries are monitored continuously to tune out false positives and optimize alerting thresholds.
