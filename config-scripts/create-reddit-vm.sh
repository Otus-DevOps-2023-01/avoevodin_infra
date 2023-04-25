#!/bin/bash
sudo apt update
sleep 5
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=2 \
  --create-boot-disk image-id=fd8vhb226c1pvvc4q468,size=15GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/ycloud.pub
