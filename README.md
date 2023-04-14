# avoevodin_infra
avoevodin Infra repository

## One line someinternal host connection:
```shell
ssh -i ~/.ssh/ycloud -A -J ycloud@62.84.113.223 ycloud@10.128.0.25
```

## Directly connection to someinternal host:

* Configure ~/.ssh/config:
```text
Host bastion
HostName EXTERNAL_IP
User d

Host wikispy
HostName INTERNAL_IP
User d
ProxyCommand ssh bastion nc -q0 %h 22
```
* Connect to someinternalhost:
```shell
ssh someinternalhost
```

## VPN with Pritunl:
* Deploy VPN server with VPN/setupvpn.sh script
* HTTPS certificate: to automaticaly configure a signed SSL certificate from Lets Encrypt enter the domain name 51.250.13.192.sslip.io using sslip.io to Lets Encrypt Domain field for Pritunl settings.
* VPN settings for tests:
```text
bastion_IP = 51.250.13.192
someinternalhost_IP = 10.128.0.32
```

## Cloud test-app
* Install yc CLI  with [instruction](https://cloud.yandex.ru/docs/cli/operations/install-cli)
* Check if yc CLI is working:
```shell
yc config list
```
* Check if your yc CLI profile in ACTIVE status:
```shell
yc config profile list
```
### Create and config server manually
* Create server with yc CLI:
```shell
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --ssh-key ~/.ssh/ycloud.pub
```
* Connect to created server:
```shell
ssh ycloud@62.84.127.5
```
* Run scripts manually or from files to install dependencies and run the reddit app: install_ruby.sh, install_mongodb.sh, deploy.sh
* To copy scripts files to server run the  next command:
```shell
scp install_mongodb.sh ycloud@62.84.127.5:/home/ycloud/install_mongodb.sh
```
### Create and config server automatically with cloud-init config script
* Create server with startup config script:
```shell
yc compute instance create \
  --name reddit-app \
  --hostname reddit-app \
  --memory=4 \
  --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
  --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
  --metadata serial-port-enable=1 \
  --metadata-from-file user-data=startup.yaml
```
### Settings for test:
```test
testapp_IP = 62.84.127.5
testapp_port = 9292
```
