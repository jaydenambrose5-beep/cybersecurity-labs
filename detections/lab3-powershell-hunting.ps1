# Lab 3: Windows Security Monitoring - PowerShell hunting queries
# Run on DC01 in an elevated PowerShell window.

# Event 4728: who was added to a security group (e.g., Domain Admins)
Get-WinEvent -FilterHashtable @{LogName='Security'; Id=4728} -MaxEvents 5 |
    Format-List TimeCreated, Message

# Sysmon Event 1: find processes launched with an encoded PowerShell command
Get-WinEvent -LogName 'Microsoft-Windows-Sysmon/Operational' -FilterXPath "*[System[EventID=1]]" -MaxEvents 100 |
    Where-Object { $_.Message -like '*EncodedCommand*' } |
    Select-Object -First 1 |
    Format-List TimeCreated, Message

# PowerShell Event 4104: script block logging shows the decoded command
Get-WinEvent -LogName 'Microsoft-Windows-PowerShell/Operational' -FilterXPath "*[System[EventID=4104]]" -MaxEvents 50 |
    Where-Object { $_.Message -like '*Hello from the lab*' } |
    Select-Object -First 1 |
    Format-List TimeCreated, Message

# Verify the response: confirm who is in Domain Admins after cleanup
Get-ADGroupMember "Domain Admins" | Select-Object Name
