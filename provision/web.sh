#!/bin/bash

echo "#### Updating packages"
apt-get update -y

echo "#### Installing Nginx"
apt-get install -y nginx

echo "####Start and enable Nginx"
sudo systemctl start nginx
sudo systemctl enable nginx
