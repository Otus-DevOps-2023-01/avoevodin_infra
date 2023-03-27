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
