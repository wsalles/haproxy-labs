#!/bin/bash

sudo apt update -y
sudo apt install nginx vim -y
sudo systemctl enable nginx
sudo echo "<h1>$(hostname -f): Hello World!</h1>" > /usr/share/nginx/html/index.html
sudo systemctl start nginx