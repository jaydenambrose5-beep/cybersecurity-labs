# Lab 4: Splunk SPL Queries

All queries below were run in Splunk Cloud against logs forwarded from DC01 (Windows Server 2025).

## Dashboard panels

**Logs by Source** - how much each log source is sending:

```spl
index=* host=DC01 | stats count by sourcetype
```

**Top Security Event Codes** - which Security events happened, most common first:

```spl
index=* host=DC01 sourcetype="WinEventLog:Security" | stats count by EventCode | sort -count
```

## Detection searches

### 1. New account added to a privileged group (4720 + 4728)

```spl
index=* host=DC01 sourcetype="WinEventLog:Security" (EventCode=4720 OR EventCode=4728)
| table _time EventCode Message
| sort _time
```

**Tested:** Found `svc-update` created by `labadmin` (4720) and added to Domain Admins (4728) **1 second later**. That timing is the red flag.

### 2. Possible password guessing (4625)

Flags any account with 3 or more failed logons in a 5-minute window.

```spl
index=* host=DC01 sourcetype="WinEventLog:Security" EventCode=4625
| eval Target_Account=mvindex(Account_Name,-1)
| bin _time span=5m
| stats count by _time, Target_Account
| where count >= 3
```

**Tested:** Returned one row: `scarter`, 3 failures. The `mvindex` line is needed because 4625 events list two account names; the last one is the account being targeted.

### 3. Scheduled task created or deleted (4698 + 4699)

```spl
index=* host=DC01 sourcetype="WinEventLog:Security" (EventCode=4698 OR EventCode=4699)
| rex field=Message "Task Name:\s+(?<Task_Name>\S+)"
| table _time EventCode Task_Name
| sort _time
```

**Tested:** `\WindowsDefenderCheck` created (4698) and deleted (4699) about 4 minutes later. The `rex` line pulls the task name out of the long message.

### 4. Encoded PowerShell command (Sysmon Event 1)

```spl
index=* host=DC01 sourcetype="WinEventLog:Microsoft-Windows-Sysmon/Operational" EventCode=1 CommandLine="*EncodedCommand*"
NOT CommandLine="*SplunkUniversalForwarder*"
| table _time User CommandLine
```

**Tested:** No encoded command reached Splunk during this lab (the Lab 3 test ran before the forwarder was installed). I validated the query logic by searching for all PowerShell launches, which returned 1,589 events.

**Tuning:** every one of those events was `splunk-powershell.exe` run by SYSTEM once a minute: the forwarder itself. The `NOT CommandLine="*SplunkUniversalForwarder*"` line filters out that noise. The encoded-command trigger was confirmed in Lab 3 using `Get-WinEvent` (see [lab3-powershell-hunting.ps1](lab3-powershell-hunting.ps1)).
