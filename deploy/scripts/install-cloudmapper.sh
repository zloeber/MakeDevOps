#!/bin/bash
# installs cloudmapper on centos based system

echo 'Installing Centos requirements'
sudo yum install -y autoconf automake libtool python3-devel.x86_64 python3-tkinter jq gcc openssl-devel bzip2-devel libffi-devel

echo 'Installing Python 3.7.0'
pushd /tmp
wget https://www.python.org/ftp/python/3.7.0/Python-3.7.0.tgz
tar xzvf /tmp/Python-3.7.0.tgz
cd Python-3.7.0
./configure --enable-optimizations
sudo make altinstall
popd

echo 'Installing Cloudmaper'
git clone https://github.com/duo-labs/cloudmapper.git
cd cloudmapper/
pipenv install --skip-lock --python python3.7
pipenv shell --python python3.7