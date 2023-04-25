#!/bin/bash

# Go to home directory
cd /home/ycloud

# Install git
apt install git -y

# Clone app repository
git clone -b monolith https://github.com/express42/reddit.git

# Install app
cd reddit && bundle install

# Run app
puma -d
