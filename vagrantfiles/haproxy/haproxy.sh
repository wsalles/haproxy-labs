#!/bin/bash

# rsyslog
sudo mkdir -p /var/lib/haproxy/dev
sudo cat <<- EOF > /etc/rsyslog.d/haproxy.conf
\$AddUnixListenSocket /var/lib/haproxy/dev/log

# Send HAProxy messages to a dedicated logfile
:programname, startswith, "haproxy" {
  /var/log/haproxy.log
  stop
}

EOF

# HA-Proxy setup
sudo mkdir -p /etc/haproxy/
sudo cp /tmp/haproxy.cfg /etc/haproxy/haproxy.cfg

# Applying the new configuration
sudo systemctl restart rsyslog
sudo systemctl restart haproxy
