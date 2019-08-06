#!/bin/bash
echo "Enabling syncthing"

apt install curl apt-transport-https -y
curl -s https://syncthing.net/release-key.txt | apt-key add -
echo "deb https://apt.syncthing.net/ syncthing release" > /etc/apt/sources.list.d/syncthing.list
apt update
apt install syncthing -y

echo << EOT >> /etc/systemd/system/syncing@.service
[Unit]
Description=Syncthing - Open Source Continuous File Synchronization for %I
Documentation=man:syncthing(1)
After=network.target

[Service]
User=%i
ExecStart=/usr/bin/syncthing -no-browser -gui-address="192.168.1.199:8384" -no-restart -logflags=0
Restart=on-failure
SuccessExitStatus=3 4
RestartForceExitStatus=3 4

[Install]
WantedBy=multi-user.target
EOT

echo "fs.inotify.max_user_watches=204800" | tee -a /etc/sysctl.conf
echo 204800 > /proc/sys/fs/inotify/max_user_watches

systemctl daemon-reload
systemctl enable syncthing@zloeber
systemctl start syncthing@zloeber

