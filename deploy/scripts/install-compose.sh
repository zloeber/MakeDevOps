#!/bin/sh

COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)

echo "Setting up docker compose - ${COMPOSE_VERSION}"
curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
chmod +x /tmp/docker-compose
mv /tmp/docker-compose /usr/bin/docker-compose

echo "Setting up docker auto-complete"
curl -L https://raw.githubusercontent.com/docker/compose/${COMPOSE_VERSION}/contrib/completion/bash/docker-compose > /tmp/docker-compose.comp
mkdir -p /etc/bash_completion.d
mv /tmp/docker-compose.comp /etc/bash_completion.d/docker-compose