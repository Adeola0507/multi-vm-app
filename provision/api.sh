#!/bin/bash

echo "#### Updating packages"
apt-get update -y

echo "#### Installing Node.js"
rm -f /etc/apt/sources.list.d/nodesource.list
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

echo "#### Installing npm"
#npm comes bundled with Node.js — no separate install needed
node --version
npm --version
