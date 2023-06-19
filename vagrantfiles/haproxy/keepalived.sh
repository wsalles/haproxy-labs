#!/bin/bash
sudo cp /tmp/keepalived.conf /etc/keepalived/keepalived.conf
sudo systemctl daemon-reload
sudo systemctl restart keepalived