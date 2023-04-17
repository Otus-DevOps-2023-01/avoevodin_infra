#!/bin/bash
apt update
apt install mongodb -y

# start MongoDB
systemctl start mongodb
systemctl enable mongod
