#!/bin/bash


wget https://github.com/keeweb/keeweb/releases/download/v1.6.3/KeeWeb-1.6.3.linux.x64.deb
sudo apt-get install libgconf2-4 -y
sudo dpkg -i KeeWeb-*.deb
