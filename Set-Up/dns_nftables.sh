#!/bin/bash

# NJIT NCAE 2026 nftables Transition Script
echo "Converting IPTables logic to modern nftables..."

if [[ $EUID -ne 0 ]]; then
echo "This script must be run as root!"
exit 1
fi

# Define Variables
ROUTER="192.168.9.1"
BACKUP="192.168.9.15"
COMP_DNS="172.18.0.12"
INT_LAN="172.16.0.0/12"
EXT_LAN="192.168.0.0/16"

echo "[*] Disabling firewalld..."
systemctl disable --now firewalld 2>/dev/null || true

# Using 'inet' for dual-stack support
cat << EOF > /etc/nftables.conf
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
chain input {
type filter hook input priority 0; policy drop;
iifname "lo" accept
ct state established,related accept
tcp dport 22 accept comment "Allow SSH"
tcp dport 53 accept comment "Allow DNS TCP"
udp dport 53 accept comment "Allow DNS UDP"
}
chain forward {
type filter hook forward priority 0; policy drop;
}
chain output {
type filter hook output priority 0; policy accept;
ip daddr $COMP_DNS ct state new,established accept
ip daddr { $INT_LAN, $EXT_LAN } ct state new reject
}
}
EOF

chmod 644 /etc/nftables.conf

echo "[*] Validating nftables syntax..."
if nft -c -f /etc/nftables.conf; then
echo "[*] Loading nftables rules..."
nft -f /etc/nftables.conf
systemctl enable --now nftables
echo "------------------------------------------------"
echo "SUCCESS: nftables is active and configured."
else
echo "------------------------------------------------"
echo "ERROR: Syntax error detected in /etc/nftables.conf"
exit 1
fi

echo "[*] Current Ruleset Summary:"
nft list ruleset | grep -E "chain|table|policy"

