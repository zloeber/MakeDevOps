#!/bin/bash

echo "Installing essentials"
sudo apt-get update && sudo apt-get -y dist-upgrade
sudo apt-get -y install ubuntu-restricted-addons ubuntu-restricted-extras git openssh-server

sudo systemctl enable ssh
sudo systemctl start ssh

sudo ./bootstrap-ubuntu.sh
sudo groupadd docker
sudo gpasswd -a $USER docker
newgrp docker

echo "Installing zgen (zsh plugin manager)"
git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"

#echo "Installing oh-my-zsh"
#wget --no-check-certificate https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | sh

echo "Setting default shell to zsh"
chsh -s /bin/zsh 

if [ ! -f ~/.zshrc ]
then
    echo ".zshrc not found, creating..."
    cp ../config/.z* ~
fi

echo "For updated shell to take effect you may need to logout first."
echo ""
echo "Update/activate zsh configuration: source ~/.zshrc"
