<#
.SYNOPSIS
    Read-only hardware and virtualization inventory for home-lab planning.
.DESCRIPTION
    Collects CPU, RAM, GPU, disk, volume, OS, network, and virtualization-security
    information using built-in CIM/WMI and storage cmdlets. Makes NO changes.
.NOTES
    Lab 9 - Home lab v2: hardware assessment and architecture redesign
    Run in Windows PowerShell (no admin required).
#>

function Show-Section($title) { Write-Host "`n=== $title ===" -ForegroundColor Cyan }

Show-Section "Host"
"Hostname: $env:COMPUTERNAME"
Get-CimInstance Win32_ComputerSystem | Format-List Manufacturer, Model, HypervisorPresent

Show-Section "CPU"
Get-CimInstance Win32_Processor |
    Format-List Name, NumberOfCores, NumberOfLogicalProcessors,
                VirtualizationFirmwareEnabled, SecondLevelAddressTranslationExtensions

Show-Section "RAM"
Get-CimInstance Win32_PhysicalMemory |
    Format-Table DeviceLocator, @{n='SizeGB';e={$_.Capacity/1GB}}, Speed, Manufacturer -AutoSize
"Total RAM slots: " + (Get-CimInstance Win32_PhysicalMemoryArray).MemoryDevices

Show-Section "GPU"
Get-CimInstance Win32_VideoController | Format-Table Name, DriverVersion -AutoSize

Show-Section "Physical disks"
Get-PhysicalDisk |
    Format-Table FriendlyName, MediaType, BusType, @{n='SizeGB';e={[math]::Round($_.Size/1GB)}} -AutoSize

Show-Section "Volumes"
Get-Volume | Where-Object DriveLetter |
    Format-Table DriveLetter, FileSystemLabel,
        @{n='SizeGB';e={[math]::Round($_.Size/1GB)}},
        @{n='FreeGB';e={[math]::Round($_.SizeRemaining/1GB)}} -AutoSize

Show-Section "Operating system"
Get-CimInstance Win32_OperatingSystem | Format-List Caption, Version, BuildNumber, OSArchitecture

Show-Section "Network adapters"
Get-NetAdapter | Format-Table Name, InterfaceDescription, Status, LinkSpeed -AutoSize

Show-Section "Virtualization-based security"
# VirtualizationBasedSecurityStatus: 0 = off, 1 = enabled not running, 2 = running
# SecurityServicesRunning: 1 = Credential Guard, 2 = Memory Integrity (HVCI)
Get-CimInstance -Namespace root\Microsoft\Windows\DeviceGuard -ClassName Win32_DeviceGuard |
    Format-List VirtualizationBasedSecurityStatus, SecurityServicesRunning

Show-Section "Hypervisor software"
"VirtualBox installed: " + (Test-Path "C:\Program Files\Oracle\VirtualBox")
"VMware Workstation installed: " + (Test-Path "C:\Program Files (x86)\VMware\VMware Workstation")
