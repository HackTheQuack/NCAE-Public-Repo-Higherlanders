# Initial Access

First steps to run once VMs are accessible. **Not for MikroTik router.**

**When running scripts:** Don't paste them directly into console. Paste them into a text file with vim, `chmod +x` the file, and run the file.

1. Set machine hostname:
    * `hostnamectl set-hostname web`
    * `hostnamectl set-hostname db`
    * `hostnamectl set-hostname dns`
    * `hostnamectl set-hostname shell`
    * `hostnamectl set-hostname backup`
    * `hostnamectl set-hostname kali`

2. Setup IP addresses:
    1. Copy [setup-networking](../2026-Set-Up/2026_FireWall/setup-networking) into a script.
    2. Edit the IP, GATEWAY, and DNS variables to the appropriate values.
    3. `chmod +x` the file.
    4. Run the script.

3. Check for bad login scripts:
    * `/etc/profile`
    * `/etc/profile.d/*`
    * `/etc/bash.bashrc`
    * `/etc/bashrc`
    * `/etc/skel/.bashrc`
    * `/etc/skel/.profile`
    * `/etc/skel/.bash_profile`
    * **This does not have to be a fine comb search, but at least skim.**

4. Check `/usr/local/bin` and `/usr/local/sbin` for bad executables.
    * These should probably just be empty.

5. Run firewall setup scripts.

    1. Ensure that you run the correct script for the correct machine (the [team1](../2026-Set-Up/2026_FireWall/) directory has the latest scripts).
    2. Copy script to a file.
    3. `chmod +x` the file.
    4. Run the file.
    5. Paste [iptables-restore.service](../2026-Set-Up/2026_FireWall/iptables-restore.service) to `/etc/systemd/system/iptables-restore.service`.
    6. Run `systemctl daemon-reload`
    7. Run `systemctl disable --now firewalld.service` (it's okay if this fails).
    8. Run `systemctl enable iptables-restore`
    * Future changes to firewall will require running the save commands at the bottom of the firewall scripts.

6. Check for bad processes and connections.
    1. `ps aux`
    2. `netstat -tunap`
    3. `systemctl list-sockets`
    4. `systemctl list-timers`
    5. `systemctl list-units`
    * Found something? Quickest method to get rid of is quarantine.
      1. Kill the process.
      2. `mkdir /usr/quarantine`
      3. `mv <EXECUTABLE> /usr/quarantine`

7. Run [remote-ssh-setup](../2026-Set-Up/remote-ssh-setup).

    * **Do not run the script from the GitHub.** A script with our public keys/names will be sent in Discord.
    * For the local access user, use the password that is in the team's spreadsheet (there is a passwords tab).
    * **If you are on the Shell/FTP machine:** The script will add a group limitation to who can sign in via SSH. This will need to be updated in `/etc/ssh/sshd_config` while setting up shell login.
    * This script will remove the root account credentials.

8. ONLY ON MACHINES WITH SSH SCORING: Run [scoring-ssh-setup](../docs/ssh/scoring-ssh-setup).
    * **Do not run the script from GitHub.** A script with usernames and the public key will be provided on Discord.

9. Disable cron/at/anacron.
    * `systemctl disable --now crond`
    * `systemctl disable --now cron`
    * `systemctl disable --now at`
    * `systemctl disable --now atd`
    * `systemctl disable --now anacron`
    * `systemctl disable --now anacrond`

12. Notify group that initial access runbook is complete. Proceed with service setup.