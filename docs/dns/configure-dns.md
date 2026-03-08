### 1) Configure global BIND settings - named.conf
- Debian - /etc/bind/named.conf.options
- RHEL - /etc/named.conf
- contains all global options such as DNS forwarding, recursion, listening interfaces, etc.
- Create log file and change all ownership to bind/named
- Debian - `mkdir -p /var/log/bind && chown bind:bind /var/log/bind && sudo chown -R bind:bind /etc/bind/zones`
-  RHEL - `mkdir -p /var/log/bind && chown named:named /var/log/bind && sudo chown -R named:named /var/named`
##### Named.conf template
```
# master DNS template for example.com
# note for BIND 8.X, logging must be FIRST
# RHEL - /etc/named.conf | Debian - /etc/bind/named.conf.options

logging {
	channel cybergames_log {
	file "/var/log/bind/cybergames.log" versions 1 size 20m;
	severity info;
	print-severity yes;
	print-time yes;
	print-category yes;
	};
	category default {
		cybergames_log;
	};
};

# next, we configure an ACL with trusted networks for the competition.  This will be the scoring server.

acl "trusted"{
	127.0.0.1;
	172.10.100.scoringserver;
};

options {
	directory "/var/cache/bind"; # DEBIAN
	# directory "var/named"; RHEL
	recursion yes;
	allow-query { trusted; };
	allow-transfer { none; };
	dnssec-validation auto;
	listen-on { any; };
	# for RHEL/external access
	# listen-on port 53 { any; };
	# allow-query-cache { trusted; };
};
```
### 2) Configure DNS Zones
- The zones define the records for domains our server will manage.
- Creation of zones is done in the same named conf file as step 1.  You define the zone, its type, and point it to the zone file location.
- example:
```
zone "example.com" {
	type master;
	file "/etc/bind/zones/db.example.com";
}
```
- For RHEL, the below is added to same file, `/etc/named.conf`
- Debian, we put this all in `/etc/bind/named.conf.local`
```
// named.conf.local

zone "." {
	type hint;
	file "/usr/share/dns/root.hints";
}

//FORWARD ZONES
zone "localhost" in {
	type master;
	file "/etc/bind/zones/db.local";
}

zone "comp.local" {
	type master;
	file "/etc/bind/zones/forward.comp.local";
	allow-update { none; };
}

zone "example.com" {
	type master;
	file "/etc/bind/zones/forward.example.com";
	allow-update { none; };
};

//REVERSE zones
zone "127.in-addr.arpa"{
	type master;
	file "/etc/bind/db.0";
}

zone "<network IP>.in-addr.arpa" {
	type master;
	file "/etc/bind/zones/reverse.comp.local";
	allow-update { none; };
};


```

### 3) Create zone files
- Make the zones directory if it doesn't exist
- `sudo mkdir -p /etc/bind/zones`
- Create the zone file in that dir, i.e. `/etc/bind/zones/db.example.com`
- Add content to define DNS records for that domain as necessary.  We will likely just need NS, PTR, A, and maybe AAAA records. 
##### Forward zone file
```
; /etc/bind/zones/forward.comp.local
$TTL    604800
@       IN     SOA    ns1.comp.local. admin.comp.local. (
						2026031401 ; serial number YYYYMMDDNN
						12h        ; refresh
						15m        ; update retry
						4d         ; expiry
						2h         ; minimum
						)
;
; name server RR for domain
@		IN      NS    ns1.comp.local.
ns1     IN      A     <THIS DNS SERVER IP> ;
www     IN      A     <web server IP>      ;
db      IN      A     <db server IP>       ;
mail    IN      A     <mail server IP>     ;
@       IN      MX 10 mail.comp.local.
; any name server external to THIS ZONE, prolly not necessary
        IN      NS    ns1.comp.net.
```

##### Reverse Zone file
```
; /etc/bind/zones/reverse.comp.local
$TTL    604800
$ORIGIN comp.local.
@       IN     SOA    ns1.comp.local. admin.comp.local. (
						2026031401 ; serial number YYYYMMDDNN
						2h         ; minimum
						)
;
; name server RR for domain
@		IN      NS    ns1.comp.local.
10     IN       PTR   ns1.comp.local.
20     IN       PTR   www.comp.local.
30     IN       PTR   db.comp.local.
40     IN       PTR   mail.comp.local.
```
### 4) Check configs before starting BIND
- Debian - `sudo named-checkconf`
- RHEL - `sudo named-checkconf /etc/named.conf`
- You can also verify the zone files!
- `sudo named-checkzone example.com /etc/bind/zones/db.example.com`


#### 5) Start/restart BIND and check status
- Debian - `sudo systemctl restart bind9`
	- `sudo systemctl status bind9`
	  
- RHEL - `sudo systemctl restart named`
	- `sudo systemctl status named`

### 6) Test the server
- We could wait for scoring, but its quick to do this
- `dig@<DNS server IP addr> example.com`
- Also reverse/PTR lookup
- `dig -x <IP addr>`

#### 7) Log checks
`tail -f /var/log/bind/cybergames.log`

#### 8) Other notes
 - Always increase serial number by 1 after every edit!
- ensure the following is allowed in the firewall
- Debian:
	- `sudo ufw allow 53/tcp && sudo ufw allow 53/udp`
- RHEL
	- `sudo firewall-cmd --add-service=dns --permanent && sudo firewall-cmd --reload`
- 