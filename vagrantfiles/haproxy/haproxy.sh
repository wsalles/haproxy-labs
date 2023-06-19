#!/bin/bash
sudo mkdir -p /etc/haproxy
sudo mkdir -p /var/lib/haproxy/dev
sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg
sudo touch /etc/default/haproxy
sudo groupadd haproxy
sudo useradd -g haproxy haproxy

sudo cat <<- EOF > /etc/rsyslog.d/haproxy.conf
\$AddUnixListenSocket /var/lib/haproxy/dev/log

# Send HAProxy messages to a dedicated logfile
:programname, startswith, "haproxy" {
  /var/log/haproxy.log
  stop
}

EOF

sudo systemctl restart rsyslog
sudo systemctl restart haproxy
