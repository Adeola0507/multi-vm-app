#!/bin/bash

echo "##############################"
echo "Updating packages"
sudo apt update -y > /dev/null
echo

echo "##############################"
echo "Installing MySQL"
sudo apt install mysql-server -y > /dev/null
echo

echo "##############################"
echo "Start & enable MySQL"
echo "##############################"
sudo systemctl start mysql
sudo systemctl enable mysql
echo

echo "##############################"
