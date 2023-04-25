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
## Packer reddit-app
* Create a new branch packer-base
* Move scripts from previous hw to config-scripts folder
* Install packer
```shell
brew tap hashicorp/tap
brew install hashicorp/tap/packer
```
### Create service account at yandex cloud:
* Create
```shell
    SVC_ACCT="yc-packer"
    FOLDER_ID="my_folder_id"
    yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
```
* Give it editor credentials:
```shell
ACCT_ID=$(yc iam service-account get $SVC_ACCT |  grep ^id | awk '{print $2}')
yc resource-manager folder add-access-binding --id $FOLDER_ID --role editor --service-account-id $ACCT_ID
```
* Create a secret key:
```shell
yc iam key create --service-account-id $ACCT_ID --output secrets/key.json
```
### Create packer template:
* Create packer config scripts
```shell
mkdir -p packer/scripts

touch packer/ubuntu16.json

cp config-scripts/install_mongodb.sh packer/scripts/

cp config-scripts/install_ruby.sh packer/scripts/
```
* Create packer config:
```json
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "secrets/key.json",
            "folder_id": "my_folder_id",
            "source_image_family": "ubuntu-1604-lts",
            "image_name": "reddit-base-{{timestamp}}",
            "image_family": "reddit-base",
            "ssh_username": "ubuntu",
            "platform_id": "standard-v1",
	        "disk_name": "reddit-base",
	        "disk_size_gb": "15",
	        "instance_mem_gb": "2",
	        "use_ipv4_nat": true
       	}
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "packer/scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "packer/scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
* Validate packer config:
```shell
packer validate packer/ubuntu16.json
```
* Build image with packer:
```shell
packer build packer/ubuntu16.json
```
* Create compute instance with builded image and check it with link "http://external_instance_ip:9292"
### Packer config with variables:
* Create variables json:
```shell
touch secrets/variables.json
```
* Example of variables.json:
```json
{
	"my_key": "./secrets/key.json",
	"my_folder_id": "some_folder_key",
	"my_image": "ubuntu-1604-lts",
	"my_disk_size": "15",
	"my_memory_gb": "2",
	"my_disk_name": "reddit-base",
	"my_image_family": "reddit-base"
}
```
* Create packer config file with variables:
```json
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "{{user `my_key`}}",
            "folder_id": "{{user `my_folder_id`}}",
            "source_image_family": "{{user `my_image`}}",
            "image_name": "{{user `my_image_family`}}-{{timestamp}}",
            "image_family": "{{user `my_image_family`}}",
            "ssh_username": "ubuntu",
            "platform_id": "standard-v1",
	        "disk_name": "{{user `my_disk_name`}}",
	        "disk_size_gb": "{{user `my_disk_size`}}",
	        "instance_mem_gb": "{{user `my_memory_gb`}}",
	        "disk_type": "{{user `my_disk_type`}}",
	        "use_ipv4_nat": true
       	}
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "packer/scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "packer/scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        }
    ]
}
```
* Note that secrets folder exist in .gitignore file.
* Other parameters of builder:
```text
instance_mem_gb, disk_type, disk_size_gb
```
* Build packer image with created config file.
### Create a bake-image
* Create packer config file immutable.json based on ubuntu16.json with additional inline commands:
```json
{
    "builders": [
        {
            "type": "yandex",
            "service_account_key_file": "{{user `my_key`}}",
            "folder_id": "{{user `my_folder_id`}}",
            "source_image_family": "{{user `my_image`}}",
            "image_name": "{{user `my_image_family`}}-{{timestamp}}",
            "image_family": "{{user `my_image_family`}}",
            "ssh_username": "ubuntu",
            "platform_id": "standard-v1",
	        "disk_name": "{{user `my_disk_name`}}",
	        "disk_size_gb": "{{user `my_disk_size`}}",
	        "instance_mem_gb": "{{user `my_memory_gb`}}",
	        "disk_type": "{{user `my_disk_type`}}",
	        "use_ipv4_nat": true
       	}
    ],
    "provisioners": [
        {
            "type": "shell",
            "script": "packer/scripts/install_ruby.sh",
            "execute_command": "sudo {{.Path}}"
        },
        {
            "type": "shell",
            "script": "packer/scripts/install_mongodb.sh",
            "execute_command": "sudo {{.Path}}"
        },
	{
	    "type": "file",
	    "source": "packer/files/puma.service",
	    "destination": "/tmp/puma.service"
	},
	{
	    "type": "shell",
	    "inline": [
		"sleep 5",
	    "sudo mv /tmp/puma.service /etc/systemd/system/puma.service",
		"cd /opt",
		"sudo apt-get install -y git",
		"sudo chmod -R 0777 /opt",
		"git clone -b monolith https://github.com/express42/reddit.git",
		"cd reddit && bundle install",
		"sudo systemctl daemon-reload && sudo systemctl start puma && sudo systemctl enable puma"
	    ]
	}
    ]
}
```
* Validate packer config:
```shell
packer validate -var-file=./secrets/variables.json ./packer/immutable.json
```
* Build packer image:
```shell
packer build -var-file=./secrets/variables.json ./packer/immutable.json
```
* Create compute instance with builded image and check app at "http://external_instance_ip:9292"
### Autocreate instance with bake-image:
* Configurate a bash script to automatically create a compute instance with builded bake-image:
```text
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
```
* Check created instance at "http://external_instance_ip:9292"
