#!/bin/bash
sudo apt update -y

# Install the Latest HAProxy Using a PPA: http://git.haproxy.org/?p=haproxy.git
HAPROXY_RELEASE=2.8
sudo apt install --no-install-recommends software-properties-common -y
sudo add-apt-repository ppa:vbernat/haproxy-${HAPROXY_RELEASE} -y

# Install all packages
sudo apt install libssl-dev keepalived haproxy -y
