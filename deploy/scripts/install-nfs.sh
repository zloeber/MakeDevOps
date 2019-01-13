#!/bin/bash
echo "NFS Server Install"

NFS_ROOT="${NFS_ROOT:-"/var/nfsroot"}"
DISK="${DISK:-"/dev/sdb"}"

echo "NFS_ROOT: ${NFS_ROOT}"
echo "DISK: ${DISK}"

mkdir -p "${NFS_ROOT}"
chmod -R 755 "${NFS_ROOT}"
chown -R nfsnobody:nfsnobody "${NFS_ROOT}"

# Prevents stdout errors when automating apt
parted -s -a optimal "${DISK}" mklabel GPT mkpart primary 0% 100% set 1 lvm on
pvcreate "${DISK}1"

vgcreate nfsroot "${DISK}1"
lvcreate -l 100%FREE -n nfs nfsroot

mkfs.ext4 /dev/mapper/nfsroot-nfs

echo "/dev/mapper/nfsroot-nfs    ${NFS_ROOT} ext4    defaults    0   2" >> /etc/fstab
mount -a
echo "${NFS_ROOT} (rw,sync,no_root_squash)" > /etc/exports

systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap