# Detection Queries

The actual searches I used to investigate activity in my home lab.

| File | Tool | Lab |
| --- | --- | --- |
| [lab3-powershell-hunting.ps1](lab3-powershell-hunting.ps1) | PowerShell `Get-WinEvent` | Lab 3: Windows security monitoring |
| [lab4-splunk-spl.md](lab4-splunk-spl.md) | Splunk SPL | Lab 4: Cloud SIEM monitoring |
| [lab5-suspicious-login.md](lab5-suspicious-login.md) | Splunk SPL + PowerShell | Lab 5: Suspicious login investigation |

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
