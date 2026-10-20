# Lab 8: Linux Security Monitoring (Splunk SPL)

Searches used to monitor an Ubuntu Server 26.04 VM (`ubuntu01`) whose `/var/log/auth.log` is forwarded to Splunk Cloud with the Universal Forwarder (`sourcetype = linux_secure`).

## Forwarder input

`/opt/splunkforwarder/etc/system/local/inputs.conf`

```ini
[monitor:///var/log/auth.log]
sourcetype = linux_secure
index = main
disabled = false
```

The forwarder runs as the low-privilege user `splunkfwd`. Instead of running it as root, I gave it read-only log access by adding it to the `adm` group (`sudo usermod -aG adm splunkfwd`).

## 1. Failed SSH logins by user and IP (tuned)

```spl
index=main host=ubuntu01 sourcetype=linux_secure ("Failed password" OR "Connection closed by authenticating user")
| rex "(Failed password for (invalid user )?|authenticating user )(?<user>\S+) (from )?(?<src_ip>\d+\.\d+\.\d+\.\d+)"
| stats count by user, src_ip
| sort -count
```

**Tested:** `fakeuser` 6, `jayden` 3.

**Tuning:** my first version only searched for `"Failed password"` and showed `jayden` = 2 when I had typed 3 wrong passwords. Pivoting on the SSH source port showed the 3rd attempt was logged as `Connection closed by authenticating user jayden ... [preauth]`. The tuned search counts both line types.

## 2. Denied sudo (privilege escalation attempt)

```spl
index=main host=ubuntu01 sourcetype=linux_secure sudo "NOT in sudoers"
| rex "sudo(\[\d+\])?:\s+(?<user>\S+)\s*:"
| rex "COMMAND=(?<command>.+)$"
| table _time user command
```

**Tested:** `intern` tried `/usr/bin/cat /etc/shadow`.

**Detection gap:** Ubuntu 26.04 uses `sudo-rs` by default. Its denied attempt ("I'm sorry intern. I'm afraid I can't do that") was not written to `auth.log` or journald, so this search returned 0 results. I switched to classic sudo (`sudo update-alternatives --config sudo` → `sudo.ws`), re-tested, and the denial was logged and detected. A stronger long-term fix is `auditd`.

## 3. New user accounts (possible backdoor)

```spl
index=main host=ubuntu01 sourcetype=linux_secure "new user:"
| rex "name=(?<new_user>[^,]+), UID=(?<uid>\d+)"
| table _time new_user uid
```

**Tested:** `intern` (UID 1002) and `splunkfwd` (UID 1001). Linux equivalent of Windows Event 4720.

## 4. SSH attempts blocked by hardening

```spl
index=main host=ubuntu01 sourcetype=linux_secure ("Invalid user" OR "not allowed because not listed in AllowUsers" OR "Connection closed by invalid user")
| rex "(Invalid user |invalid user |User )(?<user>\S+) (from )?(?<src_ip>\d+\.\d+\.\d+\.\d+)"
| stats count by user, src_ip
```

After hardening, blocked attempts no longer produce "Failed password" lines, so detection #1 alone would miss them.

## SSH hardening applied

`/etc/ssh/sshd_config.d/00-hardening.conf` (named `00-` so it is read first; the first value wins)

```text
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
MaxAuthTries 3
AllowUsers jayden
```

Verified with `sudo sshd -t` (syntax) and `sudo sshd -T` (settings in effect).

## Time sync check

```bash
timedatectl          # "System clock synchronized: no" = problem
sudo chronyc makestep
date -u
```

The VM clock had drifted 2 hours behind, so Splunk filed new events 2 hours in the past and a "Last 15 minutes" search found nothing.
