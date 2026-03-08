# OpenSSH Key-Based Authentication on Windows Server 2026

### Configuration & Troubleshooting Recap

## Overview

This document outlines the complete and correct process for configuring **OpenSSH on Windows Server 2026** to allow **public key authentication**, including handling **administrator accounts**, fixing common Windows-specific pitfalls, and validating the configuration through logs and fingerprints.

---

## 1. Install and Enable OpenSSH Server

### Verify installation

```powershell
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*'
```

### Install if missing

```powershell
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
```

### Enable and start the service

```powershell
Set-Service sshd -StartupType Automatic
Start-Service sshd
```

---

## 2. Configure the Default SSH Shell (Optional)

### Set Windows PowerShell as the default shell

By default, OpenSSH on Windows usually uses `cmd.exe` as the default shell. To set it to PowerShell as the default shell, run:

```powershell
Set-ItemProperty `
  -Path "HKLM:\SOFTWARE\OpenSSH" `
  -Name DefaultShell `
  -Value "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
```

### Restart sshd

```powershell
Restart-Service sshd
```

## Why this matters! This is important!
If the shell path is invalid, SSH authentication fails *before* key validation with errors like:

```
User not allowed because shell ... does not exist
```

---

## 3. Generate an SSH Key Pair (Client)

On the **client machine**:

```powershell
ssh-keygen -t ed25519
```

Default location:

```
~/.ssh/id_ed25519
~/.ssh/id_ed25519.pub
```

---

## 4. Understand Windows OpenSSH Admin Behavior (Critical)

Windows OpenSSH treats **Administrators** differently.

If the user is in the **Administrators** group, `sshd` ignores:

```
C:\Users\<user>\.ssh\authorized_keys
```

and instead uses:

```
C:\ProgramData\ssh\administrators_authorized_keys
```

This behavior is controlled by `sshd_config`.

---

## 5. Configure `sshd_config` for Administrators

Edit:

```
C:\ProgramData\ssh\sshd_config
```

At the bottom of the config file, you will find a block like this:

```text
Match Group administrators
    AuthorizedKeysFile __PROGRAMDATA__/ssh/administrators_authorized_keys
```

You can change the path in order to explicitly set the file path (optional but recommended):

```text
Match Group administrators
    AuthorizedKeysFile C:/ProgramData/ssh/administrators_authorized_keys
```

Restart sshd:

```powershell
Restart-Service sshd
```

---

## 6. Create the Administrator Authorized Keys File (You're gonna want to learn this)

Windows OpenSSH is very particular about the format and location of the `administrators_authorized_keys` file. If you do not create this file correctly, key-based authentication will fail.

Things to note:
* Location: `C:\ProgramData\ssh\administrators_authorized_keys` (default location unless changed in `sshd_config`)
* Encoding: ASCII or UTF-8 (no BOM)
* Permissions: Restricted (see next section)


### Create the file (if missing)

```powershell
New-Item -ItemType File -Path "C:\ProgramData\ssh\administrators_authorized_keys"
```

### Add the public key (safe method)

So far, the only reliable way I've found to add the public key correctly using PowerShell is to read it from the user's `.ssh` folder and append it to the `administrators_authorized_keys` file:

```powershell
Add-Content `
  -Path "C:\ProgramData\ssh\administrators_authorized_keys" `
  -Encoding ascii `
  -Value (Get-Content "$env:USERPROFILE\.ssh\id_ed25519.pub")
```

**Rules:** AGAIN, IMPORTANT!

* One key per line
* Starts with something like `ssh-ed25519` or whatever your key type is
* ASCII or UTF-8 (no BOM)
* No line wrapping

---

## 7. Fix Required File Permissions (ACLs)

Windows OpenSSH **will reject keys** if permissions are too open. Yes, not doing this will cause silent failures. You have been warned.

```powershell
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /inheritance:r
icacls "C:\ProgramData\ssh\administrators_authorized_keys" /grant `
  "SYSTEM:(F)" "BUILTIN\Administrators:(F)"
```

Verify:

```powershell
icacls C:\ProgramData\ssh\administrators_authorized_keys
```

Expected output:

```
BUILTIN\Administrators:(F)
NT AUTHORITY\SYSTEM:(F)
```

---

## 8. Verify the Correct Key Is Being Used (Fingerprint Check)

### On the client

```powershell
ssh-keygen -lf ~/.ssh/id_ed25519.pub
```

### On the Windows server (authorized_keys list workaround)

```powershell
Get-Content "C:\ProgramData\ssh\administrators_authorized_keys" | ForEach-Object {
    $tmp = New-TemporaryFile
    $_ | Set-Content -NoNewline -Encoding ascii $tmp
    ssh-keygen -lf $tmp
    Remove-Item $tmp -Force
}
```

Ensure the fingerprints **match exactly**.

Here is a better way to compare by saving the client fingerprint to a variable:

### On the server:

Save the client fingerprint to a variable:

**Tip**: You can use `ssh-keygen -lf ~/.ssh/id_ed25519.pub` or `ssh-add -l` on the client to get the fingerprint.
```powershell
$clientFingerprint = 'SHA256:REPLACE_WITH_YOUR_FINGERPRINT'
```

Then check if it exists in the authorized keys file. Copy and paste the following, replacing the placeholder above:
```powershell
Get-Content "C:\ProgramData\ssh\administrators_authorized_keys" | ForEach-Object {
    $tmp = New-TemporaryFile
    $_ | Set-Content -NoNewline -Encoding ascii $tmp

    $match = ssh-keygen -lf $tmp | Select-String -SimpleMatch $clientFingerprint

    if ($match) {
        Write-Output "Match found: $($match.Line)"
    }

    Remove-Item $tmp -Force
}

```

---

## 9. Enable and Read OpenSSH Logs (Troubleshooting)

### Enable logging

```powershell
wevtutil sl OpenSSH/Operational /e:true
```

### View logs

```powershell
Get-WinEvent -LogName "OpenSSH/Operational" -MaxEvents 50 |
  Select TimeCreated, Id, Message | Format-List
```

Useful messages include:

* `Failed publickey`
* `bad ownership or modes`
* `User not allowed because shell does not exist`

---

## 10. Test Key-Based Login (Client)

Force the correct key:

```powershell
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_ed25519 jude@<server-ip>
```

Successful login results in:

* No password prompt
* Immediate PowerShell session

---

## 11. Adding Additional Administrator Keys

Append additional admin keys safely:

```powershell
Add-Content `
  -Path "C:\ProgramData\ssh\administrators_authorized_keys" `
  -Encoding ascii `
  -Value 'ssh-ed25519 AAAA... user@host'
```

No restart required (but safe to do).

```powershell
Restart-Service sshd
```
## Bonus: NetFilter Firewall Rule for SSH (Optional)

I ran into this unusual issue where I needed to set the profile type for the ssh service to `Any` in order for SSH to work properly in this system. In this specific case, the default `Private` profile was causing connectivity issues on the OpenSSH.

To verify your server's firewall information. Run this as admin privileged PowerShell or cmd:
```powershell
Get-NetFirewallProfile
```

To get firewall information for the SSH rule, run:
```powershell
Get-NetFirewallRule -Name "OpenSSH*"
```
This should output something like this. Your mileage may vary:
```plaintext
Name                          : OpenSSH-Server-In-TCP
DisplayName                   : OpenSSH SSH Server (sshd)
Description                   : Inbound rule for OpenSSH SSH Server (sshd)
DisplayGroup                  : OpenSSH Server
Group                         : OpenSSH Server
Enabled                       : True
Profile                       : Any
Platform                      : {}
Direction                     : Inbound
Action                        : Allow
EdgeTraversalPolicy           : Block
LooseSourceMapping            : False
LocalOnlyMapping              : False
Owner                         :
PrimaryStatus                 : OK
Status                        : The rule was parsed successfully from the store. (65536)
EnforcementStatus             : NotApplicable
PolicyStoreSource             : PersistentStore
PolicyStoreSourceType         : Local
RemoteDynamicKeywordAddresses : {}
PolicyAppId                   :
PackageFamilyName             :
```

To change the service profile to something like `Any` or `Public`, run this in admin privileged PowerShell or cmd:
```powershell
Set-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -Profile Any
```
Restart the sshd service:
```powershell
Restart-Service sshd
```
