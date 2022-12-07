#!/bin/bash

# Check if the system package manager is apt, dnf, yum, xbps, pacman, or zypper
if [ "$(command -v apt)" ]; then
  # Use apt to install unbound
  sudo apt install unbound
elif [ "$(command -v dnf)" ]; then
  # Use dnf to install unbound
  sudo dnf install unbound
elif [ "$(command -v yum)" ]; then
  # Use yum to install unbound
  sudo yum install unbound
elif [ "$(command -v xbps)" ]; then
  # Use xbps to install unbound
  sudo xbps-install -Su unbound
elif [ "$(command -v pacman)" ]; then
  # Use pacman to install unbound
  sudo pacman -S unbound
elif [ "$(command -v zypper)" ]; then
  # Use zypper to install unbound
  sudo zypper install unbound
else
  # If no package manager is detected, print an error message
  echo "Error: No package manager detected."
fi

# Check if the directory /etc/unbound/unbound.conf.d/ exists
if [ -d /etc/unbound/unbound.conf.d/ ]; then
sudo cat <<'EOT' >> /etc/unbound/unbound.conf.d/config.conf
server:
  interface: 127.0.0.1
  port: 5335
  do-ip6: no
  do-ip4: yes
  do-udp: yes
  do-tcp: yes
  # Set number of threads to use
  num-threads: 4
  # Hide DNS Server info
  hide-identity: yes
  hide-version: yes
  # Limit DNS Fraud and use DNSSEC
  harden-glue: yes
  harden-dnssec-stripped: yes
  harden-referral-path: yes
  use-caps-for-id: yes
  harden-algo-downgrade: no
  qname-minimisation: yes
  aggressive-nsec: yes
  rrset-roundrobin: yes

  # If DNSSEC isnt working uncomment the following line
  # auto-trust-anchor-file: "/var/lib/unbound/root.key"


  # Minimum lifetime of cache entries in seconds
  cache-min-ttl: 300
  # Configure TTL of Cache
  cache-max-ttl: 14400
  # Optimizations
  msg-cache-slabs: 8
  rrset-cache-slabs: 8
  infra-cache-slabs: 8
  key-cache-slabs: 8
  serve-expired: yes
  serve-expired-ttl: 3600
  edns-buffer-size: 1232
  prefetch: yes
  prefetch-key: yes
  target-fetch-policy: "3 2 1 1 1"
  unwanted-reply-threshold: 10000000
  # Set cache size
  rrset-cache-size: 256m
  msg-cache-size: 128m
  # increase buffer size so that no messages are lost in traffic spikes
  so-rcvbuf: 1m
  private-address: 192.168.0.0/16
  private-address: 169.254.0.0/16
  private-address: 172.16.0.0/12
  private-address: 10.0.0.0/8
  private-address: fd00::/8
  private-address: fe80::/10

EOT

# Check if the system uses sysvinit
if [ -f /etc/init.d/unbound ]; then
  sudo /etc/init.d/unbound restart

# Check if the system uses systemctl
elif [ -f /usr/bin/systemctl ]; then
  sudo systemctl restart unbound

# Check if the system uses OpenRC
elif [ -f /etc/init.d/openrc ]; then
  sudo /etc/init.d/unbound restart

# Check if the system uses runit
elif [ -f /etc/service/unbound/run ]; then
  sudo sv restart unbound

# If no known init system is detected, print an error message
else
  echo "Error: Unknown init system, manually restart unbound"
  exit 1
fi
echo "unbound is installed and listening on port 5335 set Pihole or AGH to use 127.0.0.1#5335 or 127.0.0.1:5335 respectively"
done
