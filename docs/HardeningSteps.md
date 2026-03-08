# **Hardening Runbook**

## **1. Install LinPEAS and chkrootkit**
### **LinPEAS**
```bash
curl -L https://github.com/carlospolop/PEASS-ng/releases/latest/download/linpeas.sh -o /usr/local/bin/linpeas.sh
chmod +x /usr/local/bin/linpeas.sh
```

### **chkrootkit**
```bash
sudo apt update && sudo apt install chkrootkit -y
```

---

## **2. Execute LinPEAS and chkrootkit**
### **Run LinPEAS**
```bash
/usr/local/bin/linpeas.sh | tee /var/log/linpeas_output.txt
```

### **Run chkrootkit**
```bash
sudo chkrootkit | tee /var/log/chkrootkit_output.txt
```

---

## **3. Schedule Automatic Scans**
### **Set Up Cron Jobs**
```bash
echo "0 3 * * * /usr/local/bin/linpeas.sh | tee /var/log/linpeas.log" | sudo tee -a /etc/crontab
echo "0 4 * * * sudo chkrootkit | tee /var/log/chkrootkit.log" | sudo tee -a /etc/crontab
```

---

## **4. Incident Response Steps**
### **If LinPEAS Flags Vulnerabilities**
1. **Review Output**:
   ```bash
   cat /var/log/linpeas.log | less
   ```
2. **Patch Vulnerabilities**:
   - Update the system:  
     ```bash
     sudo apt update && sudo apt upgrade -y
     ```
   - Disable or restrict identified risky services.

### **If chkrootkit Detects an Infection**
1. **Review chkrootkit Logs**:
   ```bash
   cat /var/log/chkrootkit.log | grep -i "INFECTED"
   ```
2. **Isolate the System**:
   ```bash
   sudo ifconfig eth0 down
   ```
3. **Check Running Processes**:
   ```bash
   ps aux --sort=-%cpu | head -20
   ```
4. **Terminate Malicious Processes**:
   ```bash
   sudo kill -9 <PID>
   ```
5. **Check for Unauthorized Users**:
   ```bash
   sudo last -a | head -10
   sudo cat /etc/passwd
   ```
6. **Restore from Backup** if necessary.

## **5. Additional Security Hardening**

### **Verify System Binaries and Configurations**
```bash
which which
which who
which alias
alias
```

### **Check Network and Package Configurations**
```bash
cat /etc/hosts
cat /etc/nsswitch.conf
ls /etc/apt/sources.list.d/
ls /etc/yum.repos.d/
ls /etc/dnf.repos.d/
```

### **Check File Integrity**
```bash
sudo debsums -c  # Debian-based
sudo rpm -Va      # RHEL-based
```

### **Check for bad SSH keys**
* Add list of our public keys
```bash
find /home/*/.ssh/authorized_keys -type f -exec grep -L "OUR_TEAM_PUBLIC_KEYS" {} \; -delete
```

## **6. Maybe set up File Integrity Monitoring (AIDE)**
* Only do this is the system is in a known safe state (no backdoors or vulnerabilities)

```bash
sudo apt install aide -y
sudo aideinit
sudo mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
```
#### **Set up chron job to run AIDE checks**
```bash
echo "*/30 * * * * sudo aide --check | tee -a /var/log/aide.log" | sudo tee -a /etc/crontab
```
## **7. Static ARP Entries on Linux**

1. Find the interface in use with `ip addr`.
2. Paste the [arp-setup](../arp-setup) script into `/etc/NetworkManager/dispatcher.d/pre-up.d/arp-setup`.

      * **Don't use the one from GitHub.** Use the one in Discord with the mac addresses and IPs.
      * Replace `INTERFACE` with the interface from step 1.

3. Copy anything below `ARP COMMANDS` into a shell script and run it.

## **8. Static ARP Entries for MikroTik**

1. Paste the setup script in [mikrotik-arp-setup.rsc](../mikrotik-arp-setup.rsc).

      * **Don't use the one in GitHub.** Use the one in Discord with mac addresses and IP addresses.
