# Detection Queries

The actual searches I used to investigate activity in my home lab.

| File | Tool | Lab |
| --- | --- | --- |
| [lab3-powershell-hunting.ps1](lab3-powershell-hunting.ps1) | PowerShell `Get-WinEvent` | Lab 3: Windows security monitoring |
| [lab4-splunk-spl.md](lab4-splunk-spl.md) | Splunk SPL | Lab 4: Cloud SIEM monitoring |
| [lab5-suspicious-login.md](lab5-suspicious-login.md) | Splunk SPL + PowerShell | Lab 5: Suspicious login investigation |
| [lab6-phishing-analysis.ps1](lab6-phishing-analysis.ps1) | PowerShell | Lab 6: Phishing email analysis |
| [lab6-sample-phish.eml](lab6-sample-phish.eml) | Sample email (fictional domains) | Lab 6: Phishing email analysis |

## Event IDs used

| Event ID | Log | Meaning |
| --- | --- | --- |
| 4624 | Security | Successful logon |
| 4625 | Security | Failed logon |
| 4688 | Security | New process created |
| 4698 / 4699 | Security | Scheduled task created / deleted |
| 4720 | Security | User account created |
| 4722 | Security | User account enabled |
| 4724 | Security | Password reset by an admin |
| 4725 | Security | User account disabled |
| 4728 / 4729 | Security | Member added to / removed from a security group |
| 4740 | Security | Account locked out |
| 4771 | Security | Kerberos login failed (domain controller) |
| 4776 | Security | NTLM credential check (domain controller) |
| 1 | Sysmon | Process create (with full command line) |
| 4104 | PowerShell Operational | Script block logging (decoded PowerShell) |

## Email checks used (Lab 6)

| Check | What it means |
| --- | --- |
| SPF | Is the sending server allowed to send for that domain? |
| DKIM | Is the email digitally signed and unchanged? |
| DMARC | What the receiving server should do when SPF/DKIM fail (none, quarantine, reject) |
| From vs Reply-To vs Return-Path | Should share a domain; a mismatch is a red flag |
| Link text vs href | The text shown can differ from where the link really goes |
