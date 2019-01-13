### Examples Only

These scripts are here for example purposes only (but should be fine to use in most scenarios where you want to setup an NFS based local persistent StorageClass in Kubernetes single host deployments on docker-ce for the Mac.

These files are all generated automatically on your master node at provisioning time in Vagrant but have been included here for use separately for mac based NFS deployments outside of Vagrant.

To use the nfs install scripts simply modify env_vars.sh to suit your requirements then run in this order. You may have to wait some time after the first script for everything to come back up to then run the next script.
- install-nfs-mac.sh
- install-pvs-nfs-mac.sh

To revert back to hostpath for your docker-ce local deployment just run `install-pvs-hostpath-mac.sh`