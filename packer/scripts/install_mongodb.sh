#!/bin/bash
sleep 5
apt update
sleep 5
apt install mongodb -y

# start MongoDB
systemctl start mongodb
systemctl enable mongodb
