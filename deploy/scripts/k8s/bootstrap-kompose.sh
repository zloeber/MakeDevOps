#!/bin/sh

echo "Downloading and setting up kompose.."

curl -L https://github.com/kubernetes/kompose/releases/download/v1.15.0/kompose-linux-amd64 -o kompose
chmod +x ./kompose
sudo mv ./kompose /usr/local/bin/kompose
echo "source <(kompose completion bash)" >> /home/vagrant/.bashrc
echo "source <(kompose completion bash)" >> /home/vagrant/.profile

echo "Done."