#!/bin/bash
sudo mkdir -p /etc/keepalived/
sudo cp /tmp/keepalived.conf /etc/keepalived/keepalived.conf
sudo systemctl daemon-reload
sudo systemctl restart keepalived