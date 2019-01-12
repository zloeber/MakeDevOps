#!/bin/sh

COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

echo "Setting up docker compose - ${COMPOSE_VERSION}"
curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
chmod +x /tmp/docker-compose
mv /tmp/docker-compose /usr/local/bin/docker-compose

echo "Setting up docker auto-complete"
curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /tmp/docker-compose.comp
mkdir -p /etc/bash_completion.d
mv /tmp/docker-compose.comp /etc/bash_completion.d/docker-compose

mkdir -p /etc/systemd/system/docker.service.d
echo "[Service]" > /etc/systemd/system/docker.service.d/startup_options.conf
echo "ExecStart=" >> /etc/systemd/system/docker.service.d/startup_options.conf
echo "ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2376" >> /etc/systemd/system/docker.service.d/startup_options.conf

groupadd docker
usermod -aG docker $USER
systemctl enable docker

systemctl daemon-reload
systemctl restart docker.service

