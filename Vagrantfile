# -*- mode: ruby -*-
# vi: set ft=ruby :

# A Centos 7 instance that includes:
# - Commands available w/autocomplete: docker, aws
# - Dockerized platform host for container testing
# - Extra bootstrap scripts (for starting portainer and other tasks)
# - Docker (remote api published to localhost:2376)
# - A large set of make tasks for various devops exploration

### Config
$nfs_gb = 5
$nfs_disk = "nfs.vdi"
$box_image = "centos/7" #"ubuntu/xenial64"
$ports = [1313, 2049, 2376, 3000, 5000, 5080, 5432, 5555, 6379, 
8080, 8001, 8088, 8879, 9000, 9001, 9090, 9093, 4443, 60010]
#'.kube' => '/home/vagrant/.kube'
$foldersync = {
  'projects' => '/vagrant'
}
controller_name = 'SATA Controller'

def sata_controller_exists?(vm, controller_name="SATA Controller")
  (`vboxmanage showvminfo #{vm} --machinereadable | findstr " #{controller_name}"`||0) != 0
end

def port_in_use?(vm, controller_name, port)
  (`vboxmanage showvminfo #{vm} | findstr "#{controller_name} (#{port}, "`||0) != 0
end

def attach_hdd(v, controller_name, port, hdd_path)
  unless port_in_use?(v, controller_name, port)
    v.customize ['storageattach', v, '--storagectl', controller_name, '--port', port, '--device', 0, '--type', 'hdd', '--medium', hdd_path]
  end
end

Vagrant.configure("2") do |config|
  file_root = File.dirname(File.expand_path(__FILE__))
  file_to_disk = File.join(file_root, $nfs_disk)
  config.vm.box = $box_image

  # Disable the default sync
  config.vm.synced_folder ".", "/vagrant", disabled: true

  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
    v.cpus = 2
    v.customize ["modifyvm", :id, "--macaddress1", "auto"]
    v.customize ["modifyvm", :id, "--vram", "7"]
    v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    v.customize ['storagectl', :id, '--name', controller_name, '--add', 'sata', '--portcount', 4] unless sata_controller_exists?(:id, controller_name)
    v.customize ['createhd', '--filename', file_to_disk, '--format', 'VDI', '--size', $nfs_gb * 1024] unless File.exist?(file_to_disk)
    attach_hdd(v, controller_name, 0, file_to_disk)
  end

  #SSH
  config.ssh.forward_agent = true
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  config.ssh.private_key_path = ["./.ssh/id_rsa_vagrant"]
  config.vm.box_check_update = true
  config.ssh.insert_key = false

  for i in $ports
    config.vm.network "forwarded_port", guest: i, host: i, auto_correct: true
  end

  #Provision Once
  # - Run updates and some installs
  # - Provision docker then change it to always listen for remote API connections
  #    (This is required to deploy Jenkins slave nodes for instance). Can test with the following:
  #    docker -H tcp://127.0.0.1:2376
  config.vm.provision "shell", inline: <<-SHELL
    yum -y install epel-release
    yum -y update && yum -y upgrade
    yum -y install curl git nano net-tools java-1.8.0-openjdk wget unzip jq kernel-headers kernel-devel lvm2 device-mapper device-mapper-persistent-data device-mapper-event device-mapper-libs device-mapper-event-libs bash-completion bash-completion-extras yum-utils tree ruby screen tmux byobu gcc openssl-devel bzip2-devel libffi-devel python-devel zlib-devel readline-devel sqlite-devel npm zsh stow socat maven nfs-utils e2fsprogs graphviz libostree-dev gpgme-devel

    sysctl net.bridge.bridge-nf-call-iptables=1
    sysctl net.bridge.bridge-nf-call-ip6tables=1

    echo 'Installing most recent docker release...'
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

    echo 'Docker - going bleeding edge!'
    yum-config-manager --enable docker-ce-edge
    yum install -y docker-ce

    echo 'Docker - setting up user permissions'
    groupadd docker -f
    usermod -aG docker vagrant

    echo 'Docker - disabling firewall'
    systemctl stop firewalld
    systemctl disable firewalld

    systemctl enable docker
      
    echo 'Enabling docker and fixing default service options to fix other issues'
    mkdir -p /etc/systemd/system/docker.service.d
    rm -rf /etc/systemd/system/docker.service.d/startup_options.conf
    echo "[Service]" > /etc/systemd/system/docker.service.d/startup_options.conf
    echo 'ExecStart=' >> /etc/systemd/system/docker.service.d/startup_options.conf
    echo 'ExecStart=/usr/bin/dockerd -H unix://var/run/docker.sock -H tcp://0.0.0.0:2376' >> /etc/systemd/system/docker.service.d/startup_options.conf
    
    echo 'Fixing docker-runc link..'
    ln -s /usr/libexec/docker/docker-runc-current /usr/libexec/docker/docker-runc 2>/dev/null || true

    echo 'Fixing docker-proxy link too..'
    ln -s /usr/libexec/docker/docker-proxy-current /usr/bin/docker-proxy 2>/dev/null || true

    systemctl daemon-reload
    systemctl restart docker.service

    #echo 'Creating baseline aws credentials file'
    #mkdir -p /home/vagrant/.aws
    #touch /home/vagrant/.aws/credentials
    #echo '[default]' > /home/vagrant/.aws/credentials
    #echo '[saml]' >> /home/vagrant/.aws/credentials

    echo 'Updating profile to set your makedevops path'
    echo "export MAKEDEVOPS_PATH='/home/vagrant'" >> /home/vagrant/.bashrc

    echo 'Adding some command line completion to your profile'
    cp -ru /home/vagrant/deploy/scripts/make.bashcomplete /etc/bash_completion.d/make

    echo 'Setting up docker-compose bash autocomplete'
    curl -L https://raw.githubusercontent.com/docker/compose/1.22.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
  
    echo 'export PATH="/home/vagrant/.local/bin:$PATH"' >> "/home/vagrant/.bashrc"
    echo 'Adding additional authorized key'
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDkO2J2qC4+TDAJPYFq/4S7ytlSPY44bXfD2fIyQDDYUebWqyUtRiT888JlJrQuO2fFO2Kn1DID0U+o9CH8l9hVIVakrUskfGuBLXYu4w2dj+b4L9VtlEjdUuXRcWnLtYPxk60LQr+iwraOZLVO8zoGRX2S/8IYUaZLKQn8eZ9DOQKwfLcZ4oKnLZJkyYUzt051DhatoBLNOHV8iMmangLh0rIYp1IKGY/Oi2PC0uRyNowsU+sDOZUnw0P2vtYDKFS3ARbRC+2pRVmE8WmxE2KPEFfxjkBVMVtQwliTCkQvjyeShIC2FXE5AYqDyV7VhS71DOFJ1JM5r5ijZNNpa/3r vagrant' >> /home/vagrant/.ssh/authorized_keys
    echo 'Resetting vagrant home directory ownership'
    chown -R vagrant:vagrant /home/vagrant
  SHELL

  # Provision script each time
  config.vm.provision "shell", run: "always", inline: <<-SHELL
    echo ' '
    echo ' '
    echo '1. Login:'
    echo '   vagrant ssh'
    echo ' '
    echo '2. Initial config:'
    echo '   make config'
    echo ' '
    echo '3. Install whatever:'
    echo '   make'
    echo ' '
    echo 'NOTE: ALL make commands should be run with a non-root account (no sudo)'
    echo ' '
    echo 'Run make for more devops bootstrap tasks. Cheers!'
  SHELL

  # Use the following to ensure that rsync does NOT follow symlinks and error out
  # (NOTE: Update the rsync__excludes to protect folders from being overwritten!)
  config.vm.synced_folder '.', '/home/vagrant', type: "rsync", rsync__exclude: [".git/", ".vagrant/", "projects/", ".kube/", ".config/"], rsync__args: ["--verbose", "--archive", "-z"]

  $foldersync.each do |key, value|
    config.vm.synced_folder "#{key}", "#{value}",
    create: true, 
    type: "virtualbox", 
    automount: true, 
    SharedFoldersEnableSymlinksCreate: true,
    owner: "vagrant",
    mount_options: ["dmode=0775,fmode=0774"]
  end
  config.vm.synced_folder "projects/mda-fork/.ssh", "/vagrant/mda-fork/.ssh",
    create: true, 
    type: "virtualbox", 
    automount: true, 
    SharedFoldersEnableSymlinksCreate: true,
    owner: "vagrant",
    mount_options: ["dmode=0775,fmode=0774"]
  end
