# Lab 5: Suspicious Login Investigation

Searches used to investigate an unexpected Sunday-morning login by a dormant account (`akim`) on DC01. All Splunk queries ran in Splunk Cloud against logs forwarded from DC01.

## 1. Account timeline (Splunk SPL)

Shows every account change and logon for one user, in order.

```spl
index=* host=DC01 sourcetype="WinEventLog:Security" (EventCode=4722 OR EventCode=4724 OR EventCode=4625 OR EventCode=4624 OR EventCode=4672) "akim"
| eval Action=case(EventCode=4722,"Account enabled", EventCode=4724,"Password reset", EventCode=4625,"Failed logon", EventCode=4624,"Successful logon", EventCode=4672,"Admin rights logon")
| table _time EventCode Action Logon_Type Source_Network_Address
| sort _time
```

**Tested:** 3 events within 2 seconds: account enabled (4722), password reset (4724), then a network logon (4624, Logon Type 3).

## 2. Failed logins on a domain controller (Splunk SPL)

On a domain controller, failed domain logins usually appear as **4771** (Kerberos) or **4776** (NTLM), not only 4625. This search checks all three.

```spl
index=* host=DC01 sourcetype="WinEventLog:Security" (EventCode=4625 OR EventCode=4771 OR EventCode=4776) "akim"
| eval Action=case(EventCode=4625,"Failed logon", EventCode=4771,"Kerberos login failed", EventCode=4776,"NTLM login check")
| table _time EventCode Action
| sort _time
```

**Tested:** First run returned **0 events**, even though 3 failed logins had happened. Kerberos failure auditing was not turned on (an audit gap). After enabling it, the search caught the failure (4771).

**Fix used:**

```powershell
auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
```

## 3. Why did the login fail? (Splunk SPL)

```spl
index=* host=DC01 sourcetype="WinEventLog:Security" EventCode=4771 "akim"
| stats count by Account_Name, Failure_Code, Client_Address
```

| Failure Code | Meaning |
| --- | --- |
| 0x18 | Wrong password |
| 0x6 | Username does not exist |
| 0x12 | Account disabled, locked, or expired |

**Tested:** Failure Code `0x18` (wrong password).

## 4. Same hunt in PowerShell (no SIEM)

```powershell
# Account changes and logons for one user in the last 24 hours
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4722,4724,4624,4771,4776; StartTime=(Get-Date).AddDays(-1)} |
  Where-Object { $_.Message -match 'akim' } |
  Select-Object TimeCreated, Id, @{n='Summary';e={($_.Message -split "`n")[0]}} |
  Sort-Object TimeCreated

# Logons outside business hours (before 7 AM, after 7 PM, or on weekends)
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4624; StartTime=(Get-Date).AddDays(-7)} |
  Where-Object { $_.TimeCreated.Hour -lt 7 -or $_.TimeCreated.Hour -ge 19 -or $_.TimeCreated.DayOfWeek -in 'Saturday','Sunday' } |
  Select-Object TimeCreated, Id -First 20
```

## 5. Off-hours logon alert idea (Splunk SPL)

```spl
index=* host=DC01 sourcetype="WinEventLog:Security" EventCode=4624 (Logon_Type=3 OR Logon_Type=10)
| eval hour=tonumber(strftime(_time,"%H")), day=strftime(_time,"%a")
| where hour<7 OR hour>=19 OR day="Sat" OR day="Sun"
| stats count min(_time) as first_seen by Account_Name
| convert ctime(first_seen)
```

**Note:** Splunk Cloud shows times in UTC unless the user time zone is changed. Adjust the hours if needed. This would also need to filter out computer accounts (names ending in `$`) to cut noise.

---

## Incident timeline template

Copy this for future investigations.

| Time | Source | Event ID | What happened | Analyst note |
| --- | --- | --- | --- | --- |
| | | | | |

**Summary:** One sentence: what happened, to which account or system, and when.

**Root cause:** Why it was possible.

**Impact:** What the attacker could reach.

**Containment:** What I did to stop it right away.

**Remediation:** What I fixed so it cannot happen the same way again.

**Detection gaps:** What I could not see, and how I fixed it.
