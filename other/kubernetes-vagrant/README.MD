# Kubernetes Vagrant
This Vagrantfile and associated scripts will setup a 3 node kubernetes cluster using kubeadm with Virtualbox.

To construct the environment clone this repo, enter the directory and run the following:
```bash
vagrant up
```
You can ignore any errors relating to IP modules. After a while the three nodes should come up with the following names:
- master
- node1
- node2

This is just a base cluster without CNI (pod networking) or persistent volumes (shared storage) configured. To make the cluster more functional you will have to start a network and setup shared storage. I've left these as optional to set that up as you please (some additional options can be found with this repo that you can change to affect how the cluster is built as well if that is your thing).

Once vagrant up has completed and you have run `vagrant ssh master` then you will want to do the following steps (in order):
1. Setup a CNI plugin
2. Configure default persistent storage
3. Install helm

> **NOTE:** The master node has everything it requires to serve as an NFS server using an additional 20Gb volume.

```bash
# Login to master node
vagrant ssh master

# Start the chosen CNI overlay plugin
./start-network.sh

# Setup nfs as the default persistent storage class
./setup-nfs.sh

# Configure helm
./bootstrap-helm.sh
```

After bootstrapping helm you may want to source the .bashrc profile to get command-line completion for the helm cli.


## Additional Scripts

I've included several scripts for installing or setting up various things. These are all included in the scripts directory and should be automatically mounted and available on the master node in `/vagrant/scripts`. Sometimes you may have to `vagrant halt` then `vagrant up` the master node to remount the volume. Additionally, the vagrant-vbguest plugin can be helpful with local share related issues.

## Troubleshooting
Here are a handful of commands that may help troubleshoot issues
```
# View the kubelet logs on a node
sudo journalctl -u kubelet

# Display all pod status and IPs
kubectl get pods --all-namespaces -o wide

# Show all nodes
kubectl get nodes

# Get cluster component status info
kubectl get componentstatuses

```