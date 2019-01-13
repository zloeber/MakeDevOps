#!/bin/sh

echo "Downloading and setting up storageos-cli.."

curl -sSLo storageos https://github.com/storageos/go-cli/releases/download/1.0.0-rc1/storageos_linux_amd64
chmod +x storageos
sudo mv storageos /usr/local/bin/

echo "Done."