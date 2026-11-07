# Lab 11: OPNsense firewall rules and log investigation

[← Lab 10](../10-opnsense-firewall-network/) · [🏠 Portfolio home](../../README.md)

| | |
| --- | --- |
| **Focus** | Networking / SOC |
| **Tools** | VirtualBox 7.2 · OPNsense 26.7 · Windows 11 Enterprise · PowerShell (`Test-NetConnection`) |
| **Skills demonstrated** | Firewall rule design · rule order (first match wins) · aliases · subnet planning · testing a control · reading raw firewall logs · incident write-up |
| **Key result** | The lab can no longer reach my home network, plain HTTP is blocked, HTTPS still works, and every block is logged with source, destination, port, protocol and time. |
| **ATT&CK mitigations** | [M1037 Filter Network Traffic](https://attack.mitre.org/mitigations/M1037/) · [M1030 Network Segmentation](https://attack.mitre.org/mitigations/M1030/) |

**Status:** Complete. Tested on 2026-11-07.

## Objective

Turn the "allow everything" firewall from Lab 10 into a real policy:

1. Understand OPNsense rules and rule order.
2. Allow approved traffic (HTTPS, DNS).
3. Block selected traffic (my home network, plain HTTP).
4. Test from the Windows 11 client.
5. Review firewall logs and blocked connections.
6. Investigate source IP, destination IP, port, protocol and timestamp.
7. Write a short incident report.

## Lab architecture

```mermaid
flowchart LR
    NET["Internet"] --- NAT["VirtualBox NAT<br/>10.0.2.0/24"]
    NAT -- "WAN em0<br/>10.0.2.15" --- FW["fw1.corp.lab<br/>OPNsense 26.7"]
    FW -- "LAN em1<br/>10.10.10.1/24" --- PC["WIN11-CLIENT01<br/>10.10.10.107 (DHCP)"]
    FW -. "BLOCKED<br/>HOME_NETS" .-> HOME["Home network<br/>192.168.1.0/24"]
```

The lab LAN moved from 192.168.1.0/24 to **10.10.10.0/24** in this lab (see Finding 1).

## Tools used

| Tool | Purpose |
| --- | --- |
| OPNsense 26.7 | Firewall rules, aliases, live and raw logs |
| VirtualBox 7.2.22 | Hosts the firewall and client VMs |
| Windows 11 Enterprise (eval) | Test client on CORP-LAN |
| `Test-NetConnection` | Repeatable allow/block tests from the client |

## Setup

- Raised the firewall VM from 2 GB to **3 GB RAM** (the OPNsense documented minimum) while powered off.
- Renumbered the LAN to **10.10.10.1/24** from the firewall console (DHCP 10.10.10.100-200).
- Renewed the client lease: it moved to **10.10.10.107**.
- Set the firewall time zone to **America/New_York** so log times match my local time.

![VM RAM raised to 3 GB](screenshots/lab11-01-opnsense-ram-3gb.png)

*Firewall VM raised to 3 GB RAM.*

![Home subnet overlap](screenshots/lab11-02-home-subnet-overlap.png)

*My real laptop is on 192.168.1.0/24, the same range the lab LAN used (username and host octet redacted).*

![LAN renumbered on the console](screenshots/lab11-03-lan-renumber-console.png)

*Renumbering the LAN from the firewall console.*

![LAN now 10.10.10.1](screenshots/lab11-04-lan-10-10-10-1.png)

*LAN is now 10.10.10.1/24.*

![Client new address](screenshots/lab11-05-client-new-address.png)

*Client renewed its lease and got 10.10.10.107.*

![Dashboard on new IP](screenshots/lab11-06-dashboard-new-ip-3gb.png)

*Dashboard reachable at the new address, 3 GB RAM shown.*

## Firewall rules created

**Before:** two default LAN rules, "allow LAN to any" for IPv4 and IPv6.

![LAN rules before](screenshots/lab11-07-lan-rules-before.png)

**Alias `HOME_NETS`** (type Network(s)): `192.168.0.0/16`, `172.16.0.0/12`, `10.0.2.0/24`. These cover my home Wi-Fi, other private ranges, and the VirtualBox NAT path back to the laptop.

**Final LAN rule order** (top to bottom; the first match wins):

| # | Action | Proto | Source | Destination | Port | Log | Why |
| --- | --- | --- | --- | --- | --- | --- | --- |
| 1 | Block | any (IPv4) | LAN net | HOME_NETS | any | ✅ | The lab must never touch my real network |
| 2 | Block | TCP (IPv4) | LAN net | any | 80 (HTTP) | ✅ | Unencrypted web traffic is not allowed |
| 3 | Pass | any (IPv4) | LAN net | any | any | | Default allow (HTTPS, DNS, etc.) |
| 4 | Pass | any (IPv6) | LAN net | any | any | | Default allow |

![Alias created](screenshots/lab11-08-alias-home-nets.png)

*HOME_NETS alias created.*

![Block rule form](screenshots/lab11-09-block-home-nets-rule-form.png)

*First version of the block rule. Source was still `any` and Log was off; both were fixed before saving.*

![Block rule in the wrong place](screenshots/lab11-10-block-rule-wrong-order.png)

*Mistake: the new block rule landed **below** the allow rule, so it would never match.*

![Alias loaded](screenshots/lab11-11-alias-loaded-3-entries.png)

*Alias active with 3 entries (Loaded# = 3).*

![Block rule moved to top](screenshots/lab11-12-block-rule-on-top.png)

*Fixed by setting the rule's **Sequence** to 1 (advanced mode).*

![HTTP rule missing port](screenshots/lab11-14-http-rule-needs-fix.png)

*Second mistake: the HTTP rule was at the bottom and had no port, which would have blocked **all** TCP.*

![HTTP rule port fixed](screenshots/lab11-15-http-rule-port-fixed.png)

*Port set to http, but a tied sequence still left it under the IPv4 allow.*

![Final rule order](screenshots/lab11-16-final-rule-order.png)

*Final order: both blocks above the allows.*

![Time zone set](screenshots/lab11-18-timezone-eastern.png)

*Time zone set to America/New_York before log review.*

## Testing methodology

Each test was run from WIN11-CLIENT01 with `Test-NetConnection`, then confirmed in the firewall log.

| Test | Command | Expected | Result |
| --- | --- | --- | --- |
| Home router blocked | `Test-NetConnection 192.168.1.1 -Port 80` | False | ✅ False |
| HTTP blocked | `Test-NetConnection neverssl.com -Port 80` | False | ✅ False |
| HTTPS allowed | `Test-NetConnection neverssl.com -Port 443` | True | ✅ True |
| Blocks logged | Plain View search | block lines with source, destination, port | ✅ Logged |

![Home router blocked](screenshots/lab11-13-test-home-router-blocked.png)

*Home router unreachable from the lab.*

![HTTP blocked, HTTPS allowed](screenshots/lab11-17-test-http-blocked-https-allowed.png)

*Port 80 False, port 443 True (the window was resized mid-output, so the text wraps).*

![Retest for logs](screenshots/lab11-19-http-retest-for-logs.png)

*Repeat of the HTTP test to generate fresh log entries after the time zone change.*

## Investigation

**Live View hid the evidence.** Live View showed only green WAN lines: the firewall's own DNS lookups filled its 25-row table. Filtering for `block` showed only old 169.254.x.x lines, matched by the built-in **Default deny** rule.

![Default deny APIPA lines](screenshots/lab11-20-default-deny-apipa-noise.png)

**Plain View had everything.** Searching the raw log (`filterlog`) for `10.10.10.107` showed the blocks:

![Raw HTTP block lines](screenshots/lab11-21-plain-view-http-blocks.png)

Decoding one line:

```
2026-11-07T00:57:04-05:00 filterlog: ...,em1,match,block,in,4,...,tcp,52,10.10.10.107,34.223.124.45,61916,80,0,S,...
```

| Field | Value | Meaning |
| --- | --- | --- |
| Timestamp | 2026-11-07 00:57:04 -05:00 | Eastern time |
| Interface / direction | em1 (LAN), in | Entering the firewall from the lab |
| Action | block | Matched rule 2 (Block HTTP) |
| Protocol | TCP | |
| Source | 10.10.10.107:61916 | WIN11-CLIENT01 |
| Destination | 34.223.124.45:80 | neverssl.com, HTTP |
| TCP flag | S (SYN) | Stopped at the first packet; no connection was made |

The same rule also blocked port-80 attempts from the client to **140.248.150.172** that I did not start. This is Windows background traffic, not my test.

**Home network evidence:**

![Home router traffic before the rule](screenshots/lab11-22-home-router-before-rule.png)

![Home router block logged](screenshots/lab11-23-home-router-block-logged.png)

At 00:59 the HOME_NETS rule logged 5 TCP SYNs to 192.168.1.1:80 (same source port, so TCP retries) and one blocked ICMP ping.

### Incident report

| | |
| --- | --- |
| **ID** | LAB11-IR-01 |
| **Severity** | Low (lab, no data exposure) |
| **Who** | Not confirmed. The WAN log shows only the NAT address 10.0.2.15, so the source could be the client or the firewall itself. Logging LAN-side passes would answer this next time. |
| **What** | Traffic from the lab reached the home router before any block rule existed. At 00:17-00:18 the firewall passed TCP 443 to 192.168.1.1 out of its WAN (NAT 10.0.2.15). |
| **When** | First seen 2026-11-07 00:17:45 EST; contained 00:30-00:41 EST |
| **Where** | fw1.corp.lab, LAN to WAN; destination = home network 192.168.1.0/24 |
| **Root cause** | The default LAN rule allowed any destination. VirtualBox NAT can route to the host's real network, so "isolated" only meant my home network couldn't reach the lab, not the other way around. |
| **Action taken** | Created the HOME_NETS alias and a logged block rule at the top of the LAN rules. Verified with `Test-NetConnection` (False) and firewall logs (5 blocked SYNs plus a blocked ping at 00:59 EST). |
| **Follow-up** | Make "no lab to home" a standing completion test for every new VM network (attack and SOC nets). |

## Results

- ✅ Lab to home network: **blocked and logged**
- ✅ HTTP (80): **blocked and logged**
- ✅ HTTPS (443): **allowed**
- ✅ Every log line gives source, destination, port, protocol and time in local time
- ✅ Subnet overlap removed; firewall at its documented minimum RAM

**Findings**

1. **Overlapping subnets.** The lab LAN (192.168.1.0/24) matched my home Wi-Fi. Renumbered to 10.10.10.0/24.
2. **Lab could reach home.** Lab 10 proved the home network couldn't reach the lab, but not the reverse. Fixed with the HOME_NETS rule.
3. **Rule order mistakes.** Both new rules first landed below the allow rule, and one had no port. Caught by checking the list, then fixed with Sequence values.
4. **Logging gap.** The 00:37 home-router test was blocked but not logged, because Log wasn't enabled yet. A rule without logging leaves no evidence.
5. **Windows uses plain HTTP in the background** (blocked to 140.248.150.172).

## Lessons learned

- The **first match wins**. A perfect block rule under an "allow any" rule does nothing. Always check the final order.
- A missing port turns "block HTTP" into "block all TCP". Read the rule back before Apply.
- Turn **Log** on when creating the rule, not later. Otherwise the evidence is gone.
- Live View is a busy summary. **Plain View (raw log) is the source of truth.**
- Isolation has two directions. Test both.
- Fix time zones before an investigation. Wrong timestamps break timelines.
- A SYN with no reply is what "blocked at the firewall" looks like in a log.

## What I would improve in a real enterprise environment

- **Default deny outbound:** allow only needed ports (443, DNS to the internal resolver, NTP) instead of block-listing.
- **Send logs to a SIEM** (Wazuh/Splunk, Lab 16) so blocks raise alerts instead of waiting in a local log.
- Force DNS through the firewall resolver and block outbound 53 elsewhere.
- **Change control:** peer review and a rollback plan for every rule change, and a config backup before edits.
- Document every rule (owner, reason, review date) and review unused rules quarterly.
- Separate VLANs per role (users, servers, management) with rules between them.
- Restrict the admin interface to a management network with MFA.

---

[← Lab 10](../10-opnsense-firewall-network/) · [🏠 Portfolio home](../../README.md)
