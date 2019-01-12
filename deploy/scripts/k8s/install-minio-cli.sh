#!/bin/bash
echo "Downloading minio client"
curl -L  https://dl.minio.io/client/mc/release/linux-amd64/mc -o mc
chmod +x ./mc
sudo mv ./mc /usr/local/bin/mc
