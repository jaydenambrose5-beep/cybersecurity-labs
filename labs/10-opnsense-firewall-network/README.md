# Lab 10: OPNsense firewall and isolated lab network

[← Lab 9](../09-home-lab-v2-architecture/) · [🏠 Portfolio home](../../README.md)

| | |
| --- | --- |
| **Focus** | Networking |
| **Tools** | VirtualBox 7.2 · OPNsense 26.7 · Windows 11 Enterprise · PowerShell |
| **Skills demonstrated** | Firewall installation · WAN/LAN design · network segmentation · DHCP troubleshooting (APIPA) · download hash verification |
| **Key result** | Built an isolated company network behind a firewall; the lab PC gets its address and internet only through it. |

**Status:** Complete. A Windows 11 lab PC on the private network gets its address from the firewall, manages it through the web dashboard, and reaches the internet only through it.

**Objective:** Build the gatekeeper for home lab v2: a firewall VM that separates a private company network (CORP-LAN) from the internet, so lab machines and future attack simulations stay sealed off from my real computer and home network.

**Setup**

- New laptop (32 GB RAM, Windows 11 Home, VBS and Memory Integrity left **on**)
- VirtualBox 7.2.22 (Expert Mode, for Internal Network options)
- OPNsense 26.7 (open-source firewall, FreeBSD based)
- Firewall VM `OPNsense-FW`: 2 GB RAM, 2 vCPU, 16 GB disk
  - **Adapter 1 / em0 = WAN:** VirtualBox NAT (internet access, 10.0.2.15)
  - **Adapter 2 / em1 = LAN:** Internal Network `CORP-LAN` (192.168.1.1/24)
- Lab PC `WIN11-CLIENT01`: Windows 11 Enterprise evaluation (90 days), 4 GB RAM, 2 vCPU, TPM 2.0 + Secure Boot, **only** connected to `CORP-LAN`
- Firewall setup wizard: hostname `fw1`, domain `corp.lab`, timezone America/New_York
- Every installer was verified with `Get-FileHash` against the vendor's published SHA256 before use

```mermaid
flowchart LR
    NET["Internet"] --- NAT["VirtualBox NAT"]
    NAT -- "WAN em0<br/>10.0.2.15" --- FW["OPNsense-FW<br/>firewall"]
    FW -- "LAN em1<br/>192.168.1.1/24" --- LAN["CORP-LAN<br/>(Internal Network)"]
    LAN --- PC["WIN11-CLIENT01<br/>192.168.1.104 (DHCP)"]
```

**Evidence**

![VirtualBox installed](screenshots/lab10-01-virtualbox-installed.png)

*Fresh VirtualBox install on the laptop.*

![VirtualBox hash verified](screenshots/lab10-02-virtualbox-hash-verified.png)

*VirtualBox installer SHA256 matched Oracle's published checksum for 7.2.22.*

![OPNsense hash verified](screenshots/lab10-03-opnsense-hash-verified.png)

*OPNsense 26.7 image SHA256 matched the official checksum file.*

![VM created](screenshots/lab10-04-opnsense-vm-created.png)

*Firewall VM created: FreeBSD 64-bit, 2 GB RAM, installer ISO attached.*

![Network adapters](screenshots/lab10-05-opnsense-network-adapters.png)

*Two adapters: NAT for the WAN and the isolated Internal Network `CORP-LAN` for the LAN.*

![Interfaces assigned](screenshots/lab10-06-opnsense-interfaces-assigned.png)

*Manual interface assignment: WAN on em0 (DHCP from NAT), LAN on em1 (192.168.1.1/24).*

![Installer](screenshots/lab10-07-opnsense-installer-start.png)

*OPNsense installer started.*

![Install complete](screenshots/lab10-08-opnsense-install-complete.png)

*Install finished; root password set (not shown).*

![Installed first boot](screenshots/lab10-09-opnsense-installed-first-boot.png)

*First boot from the virtual disk (`/dev/gpt/rootfs`) with the correct WAN/LAN mapping.*

![Final VM config](screenshots/lab10-10-opnsense-vm-final-config.png)

*Final VM state: installer ISO removed, NAT + CORP-LAN adapters.*

![Client VM created](screenshots/lab10-11-win11-client-vm-created.png)

*Windows 11 lab PC with TPM 2.0, EFI and Secure Boot.*

![Client on CORP-LAN](screenshots/lab10-12-win11-client-corp-lan.png)

*The lab PC's only network adapter is the isolated `CORP-LAN`.*

![Windows Setup](screenshots/lab10-13-win11-setup-start.png)

*Windows 11 Enterprise setup started.*

![Windows OOBE](screenshots/lab10-14-win11-oobe-region.png)

*Windows installed and reached first-time setup after a reset.*

![No DHCP](screenshots/lab10-15-client-no-dhcp-apipa.png)

*Before: a 169.254.x.x self-assigned address and no gateway, because the firewall VM was off.*

![DHCP from firewall](screenshots/lab10-16-client-dhcp-from-firewall.png)

*After: 192.168.1.104 from the firewall's DHCP, with gateway 192.168.1.1.*

![Web dashboard](screenshots/lab10-17-opnsense-web-gui-wizard.png)

*OPNsense web dashboard, reachable only from inside CORP-LAN.*

![Wizard complete](screenshots/lab10-18-opnsense-wizard-complete.png)

*Initial configuration finished: the firewall is now `fw1.corp.lab`.*

![Internet through firewall](screenshots/lab10-19-client-internet-through-firewall.png)

*The lab PC reaches the internet on HTTPS (port 443) through the firewall: `TcpTestSucceeded : True`.*

**Investigation**

| Problem | What I found |
| --- | --- |
| VMware download blocked | Broadcom's support portal requires an account, and login kept rejecting my username. |
| pfSense download | pfSense CE now ships only through the Netgate online installer with a store account. |
| Wrong network sides by default | Booting the installer without manual assignment made em0 the LAN, but em0 is the NAT (internet) adapter. |
| Firewall kept booting the installer | After install, it still showed "running in live mode from install media" because the ISO was still attached and boots first. |
| Couldn't remove the ISO | Storage settings were locked because the VM was in a **Saved** state, not powered off. |
| Black screen during Windows install | The VM showed a black screen for about 15 minutes after the first restart. |
| Lab PC had no network | `ipconfig` showed 169.254.134.65 with no gateway (APIPA). Windows makes up this address when no DHCP server answers. The firewall VM was powered off. |

**Resolution**

- Pivoted to VirtualBox (no account, already used in Labs 1-8) and OPNsense (direct download, same firewall concepts as pfSense), and still verified both downloads by hash.
- Assigned interfaces manually: **WAN = em0 (NAT)**, **LAN = em1 (CORP-LAN)**.
- Installed to disk with UFS (lighter than ZFS for a 2 GB VM).
- Discarded the saved state, removed the ISO, and confirmed boot from `/dev/gpt/rootfs` with the right interface mapping.
- Reset the stuck Windows VM; setup resumed at the region screen.
- Started the firewall first, then ran `ipconfig /renew`: the PC got 192.168.1.104 with gateway 192.168.1.1.
- Logged into the web dashboard from the lab PC at https://192.168.1.1 and completed the setup wizard.
- Confirmed internet access through the firewall with `Test-NetConnection microsoft.com -Port 443`.

**Lessons learned**

- Verify every download. A matching SHA256 proves the file is exactly what the vendor published.
- When a tool fights you, pivot. Same lesson as Lab 4: the goal is the skill, not the brand.
- Know which adapter is which. NAT = outside (WAN), Internal Network = inside (LAN). Swapping them would put the firewall backwards.
- "Saved" is not "off." VirtualBox locks hardware changes until the VM is fully powered off.
- An installed system should boot from its disk. If it still says "live mode", the installer media is still attached.
- 169.254.x.x means "no DHCP answered." Check that the DHCP server (here, the firewall) is running before blaming the client.
- Start order matters: firewall first, then the machines behind it.
- The firewall dashboard is only reachable from inside CORP-LAN. My real laptop can't reach it, which proves the isolation works.
- Next: firewall rules and logging, then an attack network for Kali behind the same firewall.

---

[← Lab 9](../09-home-lab-v2-architecture/) · [🏠 Portfolio home](../../README.md)
