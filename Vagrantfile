# -*- mode: ruby -*-
# vi: set ft=ruby :

# A Centos 7 instance that includes:
# - Python 2.7
# - Commands available w/autocomplete: docker, aws
# - Dockerized platform host for container testing
# - Extra bootstrap scripts (for starting portainer and other tasks)
# - Docker (remote api published to localhost:2376)
# - A large set of make tasks for various devops tasks

### NFS
$nfs_gb = 10

Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
  # Use the following to sync another project folder into this box
  # config.vm.synced_folder 'f:/Projects/Work/SomeProject/', '/home/vagrant/src'
  
  #config.vm.synced_folder '.', '/vagrant', disable: true

  config.vm.provider "virtualbox" do |v|
    v.memory = 8192
    v.cpus = 4
    #v.customize ["modifyvm", :id, "--macaddress1", "auto"]
    #v.customize ["modifyvm", :id, "--vram", "7"]
    v.customize ["modifyvm", :id, "--uartmode1", "disconnected"]
    #file_to_disk = File.join(file_root, "nfs.vdi")
    #unless File.exist?(file_to_disk)
    #  v.customize ['createhd', '--filename', file_to_disk, '--format', 'VDI', '--size', $nfs_gb * 1024]
    #end
    #v.customize ['storageattach', :id,  '--storagectl', 'SCSI', '--port', 2, '--type', 'hdd', '--medium', file_to_disk]
  end

  #SSH
  config.ssh.forward_agent = true
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Useful in LSW sometimes
  #config.ssh.private_key_path = ["~/Vagrant/devops-vagrant-box/private_key"]
  config.vm.box_check_update = true
  
  # Network passthrough to host
  config.vm.network "forwarded_port", guest: 1313, host: 1313, auto_correct: true
  config.vm.network "forwarded_port", guest: 2376, host: 2376, auto_correct: true
  config.vm.network "forwarded_port", guest: 5432, host: 5432, auto_correct: true
  config.vm.network "forwarded_port", guest: 5555, host: 5555, auto_correct: true
  config.vm.network "forwarded_port", guest: 6379, host: 6379, auto_correct: true
  config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
  config.vm.network "forwarded_port", guest: 8001, host: 8001, auto_correct: true
  config.vm.network "forwarded_port", guest: 8088, host: 8088, auto_correct: true
  config.vm.network "forwarded_port", guest: 9000, host: 9000, auto_correct: true
  config.vm.network "forwarded_port", guest: 4443, host: 4443, auto_correct: true
  config.vm.network "forwarded_port", guest: 60010, host: 60010, auto_correct: true

  # Example port range
  #for i in 4567..4583
  #  config.vm.network :forwarded_port, guest: i, host: i, auto_correct: true
  #end
    
  # Perform initial docker provision
  # config.vm.provision :docker

  #Provision Once
  # - Run updates and some installs
  # - Provision docker then change it to always listen for remote API connections
  #    (This is required to deploy Jenkins slave nodes for instance). Can test with the following:
  #    docker -H tcp://127.0.0.1:2376
  config.vm.provision "shell", inline: <<-SHELL
    yum -y install epel-release
    yum -y update && yum -y upgrade
    yum -y install curl git nano net-tools java-1.8.0-openjdk wget unzip jq kernel-headers kernel-devel lvm2 device-mapper device-mapper-persistent-data device-mapper-event device-mapper-libs device-mapper-event-libs bash-completion bash-completion-extras yum-utils tree ruby screen tmux byobu gcc openssl-devel bzip2-devel libffi-devel python-devel zlib-devel readline-devel sqlite-devel npm zsh stow socat maven nfs-utils parted

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

    echo 'Creating baseline aws credentials file'
    mkdir -p /home/vagrant/.aws
    touch /home/vagrant/.aws/credentials
    echo '[default]' > /home/vagrant/.aws/credentials
    echo '[saml]' >> /home/vagrant/.aws/credentials

    echo 'Updating profile to set your makedevops path'
    echo "export MAKEDEVOPS_PATH='/home/vagrant'" >> /home/vagrant/.bashrc

    echo 'Adding some command line completion to your profile'
    cp -ru /home/vagrant/deploy/scripts/make.bashcomplete /etc/bash_completion.d/make

    echo 'Setting up docker-compose bash autocomplete'
    curl -L https://raw.githubusercontent.com/docker/compose/1.22.0/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
  
    echo 'export PATH="/home/vagrant/.local/bin:$PATH"' >> "/home/vagrant/.bashrc"
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
    echo 'Run make for more devops bootstrap tasks. Update the Makefile to comment/uncomment more task libraries. Cheers!'
  SHELL
  # Use the following to ensure that rsync doesn't follow symlinks and error out
  config.vm.synced_folder '.', '/home/vagrant', type: "rsync", rsync__exclude: [".git/", ".vagrant/", "projects/", ".kube"], rsync__args: ["--verbose", "--archive", "-z"]

  config.vm.synced_folder 'projects', '/vagrant', create: true, type: "virtualbox", automount: true

  config.vm.synced_folder '.kube', '/home/vagrant/.kube', create: true, type: "virtualbox", automount: true
end

