# Lab 7: Vulnerability remediation checks (run on DC01)
# Verifies the fixes behind my Nessus re-scans. Don't trust a progress bar; check the evidence.

# 1. Was the October 2026 cumulative update installed?
Get-HotFix -Id KB5126646

# 2. Windows build revision (UBR). 33650 = October 2026 cumulative update for Windows Server 2025.
(Get-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').UBR

# 3. Is Windows Update stuck? Check free disk space first (big updates need 10-15 GB).
Get-PSDrive C | Select-Object @{n='Free GB';e={[math]::Round($_.Free/1GB,1)}}, @{n='Used GB';e={[math]::Round($_.Used/1GB,1)}}

# 4. Reset Windows Update's download cache (only if a download is stuck)
# Stop-Service wuauserv, bits -Force
# Rename-Item C:\Windows\SoftwareDistribution SoftwareDistribution.old
# Start-Service wuauserv, bits

# 5. Fix CVE-2013-3900 (WinVerifyTrust signature validation). Opt-in: no update turns it on.
foreach ($p in "HKLM:\Software\Microsoft\Cryptography\Wintrust\Config","HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config") {
  if (!(Test-Path $p)) { New-Item -Path $p -Force | Out-Null }
  New-ItemProperty -Path $p -Name EnableCertPaddingCheck -Value "1" -PropertyType String -Force
}

# 6. Verify the fix (should show EnableCertPaddingCheck = 1 in both places). Restart afterwards.
Get-ItemProperty "HKLM:\Software\Microsoft\Cryptography\Wintrust\Config","HKLM:\Software\Wow6432Node\Microsoft\Cryptography\Wintrust\Config" | Select-Object PSPath, EnableCertPaddingCheck

# 7. From the scanner (host laptop): can it reach SMB on DC01 for a credentialed scan?
# Test-NetConnection 192.168.56.101 -Port 445
