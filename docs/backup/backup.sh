#!/bin/bash

# === CONFIGURATION ===
BACKUP_ROOT="/backups"
TMP_DIR="/tmp/server_backup_temp"
DATE=$(date +"%Y-%m-%d_%H-%M-%S")
mkdir -p "$BACKUP_ROOT" "$TMP_DIR"

# Replace with actual IPs
WEB_HOST="192.168.88.10"
DNS_HOST="192.168.88.10"
FTP_HOST="192.168.88.10"
DB_HOST="192.168.88.10"
ROUTER_HOST="192.168.88.1"
REMOTE_USER="backup"  # Need to make this ssh user or use an existing one

# === FUNCTIONS ===

backup_web_server() {
    echo "Backing up Web Server from $WEB_HOST..."
    ssh "$REMOTE_USER@$WEB_HOST" "sudo tar -czf /tmp/web_config.tar.gz /etc/apache2 /var/www/html"
    scp "$REMOTE_USER@$WEB_HOST:/tmp/web_config.tar.gz" "$BACKUP_ROOT/web_backup_$DATE.tar.gz"
    ssh "$REMOTE_USER@$WEB_HOST" "rm /tmp/web_config.tar.gz"
    echo "Web server backup saved to $BACKUP_ROOT/web_backup_$DATE.tar.gz"
}

backup_dns_server() {
    echo "Backing up DNS Server from $DNS_HOST..."
    ssh "$REMOTE_USER@$DNS_HOST" "sudo tar -czf /tmp/dns_config.tar.gz /etc/bind /var/named"
    scp "$REMOTE_USER@$DNS_HOST:/tmp/dns_config.tar.gz" "$BACKUP_ROOT/dns_backup_$DATE.tar.gz"
    ssh "$REMOTE_USER@$DNS_HOST" "rm /tmp/dns_config.tar.gz"
    echo "DNS server backup saved to $BACKUP_ROOT/dns_backup_$DATE.tar.gz"
}

backup_ftp_shell() {
    echo "Backing up Shell/FTP Server from $FTP_HOST..."
    ssh "$REMOTE_USER@$FTP_HOST" "sudo tar -czf /tmp/ftp_shell_config.tar.gz /etc/ssh /etc/vsftpd.conf"
    scp "$REMOTE_USER@$FTP_HOST:/tmp/ftp_shell_config.tar.gz" "$BACKUP_ROOT/ftp_shell_backup_$DATE.tar.gz"
    ssh "$REMOTE_USER@$FTP_HOST" "rm /tmp/ftp_shell_config.tar.gz"
    echo "Shell/FTP backup saved to $BACKUP_ROOT/ftp_shell_backup_$DATE.tar.gz"
}

backup_database() {
    echo "Backing up PostgreSQL configs from $DB_HOST..."
    ssh "$REMOTE_USER@$DB_HOST" "sudo tar -czf /tmp/db_config.tar.gz /etc/postgresql /var/lib/postgresql"
    scp "$REMOTE_USER@$DB_HOST:/tmp/db_config.tar.gz" "$BACKUP_ROOT/db_backup_$DATE.tar.gz"
    ssh "$REMOTE_USER@$DB_HOST" "rm /tmp/db_config.tar.gz"
    echo "Database backup saved to $BACKUP_ROOT/db_backup_$DATE.tar.gz"
}

backup_router() {
    echo "Backing up MikroTik Router config from $ROUTER_HOST..."
    ssh "$REMOTE_USER@$ROUTER_HOST" "/export file=backup_config"
    scp "$REMOTE_USER@$ROUTER_HOST:backup_config.rsc" "$BACKUP_ROOT/router_backup_$DATE.rsc"
    ssh "$REMOTE_USER@$ROUTER_HOST" "file remove backup_config.rsc"
    echo "Router config saved to $BACKUP_ROOT/router_backup_$DATE.rsc"
}

backup_custom_directory() {
    read -rp "Enter remote host IP: " host
    read -rp "Enter full path of the directory to back up: " custom_dir

    ssh "$REMOTE_USER@$host" "sudo tar -czf /tmp/$custom_dir.tar.gz $custom_dir"
    scp "$REMOTE_USER@$host:/tmp/$custom_dir.tar.gz" "$BACKUP_ROOT/$custom_dir.$DATE.tar.gz"
    ssh "$REMOTE_USER@$host" "rm /tmp/custom_dir.tar.gz"
    echo "Custom directory backup saved to $BACKUP_ROOT/$custom_dir.$DATE.tar.gz"
}

# === MAIN MENU ===

echo "====== SERVER BACKUP MENU ======"
echo "1) Web Server"
echo "2) DNS Server"
echo "3) Shell/FTP Server"
echo "4) PostgreSQL Database"
echo "5) Router"
echo "6) Backup Custom Directory"
echo "================================"
read -rp "Select an option (1-6): " choice

case $choice in
    1) backup_web_server ;;
    2) backup_dns_server ;;
    3) backup_ftp_shell ;;
    4) backup_database ;;
    5) backup_router ;;
    6) backup_custom_directory ;;
    *) echo "Invalid option selected." ;;
esac
