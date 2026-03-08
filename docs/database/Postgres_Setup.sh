#!/usr/bin/env bash

username="<username>"
db="<database>"
ip="<IP address>"

cat > /etc/postgresql/*/main/pg_hba.conf << EOF
local $db $username scram-sha-256
host $db $username $ip/32 scram-sha-256
EOF

systemctl restart postgresql
