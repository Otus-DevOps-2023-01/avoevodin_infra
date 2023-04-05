#!/bin/bash
sudo apt update
sudo apt install mongodb -y

# start MongoDB
sudo systemctl start mongodb
sudo systemctl enable mongod
