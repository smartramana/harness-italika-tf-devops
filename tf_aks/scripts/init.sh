#!/bin/bash
#Installing Docker
sudo apt-get remove docker docker-engine docker.io
sudo apt-get update
sudo apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
sudo apt-get update
sudo apt-get install docker-ce -y
sudo usermod -a -G docker $USER
sudo systemctl enable docker
sudo systemctl restart docker
sudo docker run --name docker-nginx -p 80:80 riickster/harness-devops:latest

docker run -d \
--restart=unless-stopped \
--privileged=true \
--pid=host \
--net=host \
-v /:/mnt/root \
-e ONEAGENT_INSTALLER_SCRIPT_URL=https://wsa99408.live.dynatrace.com/api/v1/deployment/installer/agent/unix/default/latest?arch=x86 \
-e ONEAGENT_INSTALLER_DOWNLOAD_TOKEN=dt0c01.4YHECC3C4TGIYQUNVHZYQPPU.KE522SOKDJ5QOFT2UHQKJZ3ZVKB4D6FE3F2PUBMXM7F5FHX4YN7KTEFOZU5Q6POT \
dynatrace/oneagent --set-infra-only=false --set-app-log-content-access=true