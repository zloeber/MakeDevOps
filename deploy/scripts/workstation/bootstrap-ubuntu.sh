#!/bin/bash
export AUTOPILOT=true
export simulate_apt_install=false

echo "Installing post-install customization script - After Effects"

rm -rf /tmp/ubuntu-post-install
rm -rf /tmp/config-ae.yml
cp ../config/config-ae.yml /tmp/
pushd /tmp
git clone --depth 1 https://github.com/tprasadtp/ubuntu-post-install.git
cd ubuntu-post-install/
./after-effects --yaml -C ../config-ae.yml
popd


