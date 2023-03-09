# avoevodin_infra
avoevodin Infra repository

# One line someinternal host connection:
```shell
ssh -i ~/.ssh/ycloud -A -J ycloud@62.84.113.223 ycloud@10.128.0.25
```

# Directly connection to someinternal host:

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

