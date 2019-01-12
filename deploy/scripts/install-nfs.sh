echo "NFS Server Install"

NFS_ROOT="${NFS_ROOT:-"/opt/nfsroot"}"

mkdir -p "${NFS_ROOT}"
chmod -R 755 "${NFS_ROOT}"
chown nfsnobody:nfsnobody "${NFS_ROOT}"

# Prevents stdout errors when automating apt
yum -y install nfs-utils parted 

parted -s -a optimal /dev/sdc mklabel GPT mkpart primary 0% 100% set 1 lvm on
pvcreate /dev/sdc1
vgcreate kubernetes /dev/sdc1
lvcreate -l 100%FREE -n nfs kubernetes
mkfs.ext4 /dev/mapper/kubernetes-nfs
mkdir -p "${NFS_ROOT}"
echo "/dev/mapper/kubernetes-nfs    ${NFS_ROOT} ext4    defaults    0   2" >> /etc/fstab
mount -a
chown nobody:nogroup "${NFS_ROOT}"
echo "${NFS_ROOT}   0.0.0.0/0(rw,sync,no_root_squash)" >> /etc/exports

systemctl enable rpcbind
systemctl enable nfs-server
systemctl enable nfs-lock
systemctl enable nfs-idmap
systemctl start rpcbind
systemctl start nfs-server
systemctl start nfs-lock
systemctl start nfs-idmap