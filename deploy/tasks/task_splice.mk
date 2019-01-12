## Replace splice-sa with your tasks name and modify 
splice-sa_BINPATH := ${HOME}/.local/bin
INSTALL_splice-sa_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_splice-sa_TASK := .install-splice-sa-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_splice-sa_TASK := .install-splice-sa-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_splice-sa_TASK := .install-splice-sa-windows
endif

install-splice-sa: ## Downloads splice-sa binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_splice-sa_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_splice-sa_TASK)

.install-splice-sa-osx: ## Downloads and installs splice-sa (OSX)
	@echo 'Installing splice-sa'
	brew update
	brew cask install java
	brew install rlwrap
	echo 'export JAVA_HOME=`/usr/libexec/java_home`' >> ~/.bash_profile
	source ~/.bash_profile

.install-jdk8-linux: ## Quick install of oracle jdk 8 for splice-sa req.
	@echo 'Installing jdk8'
	pushd /tmp/
	wget --no-cookies --no-check-certificate --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" "https://download.oracle.com/otn-pub/java/jdk/8u191-b12/2787e4a523244c269598db4e85c51e0c/jdk-8u191-linux-x64.rpm"
	rpm -Uvh jdk-8u191-linux-x64.rpm
	popd
	echo export JAVA_HOME=/bin >/etc/profile.d/javaenv.sh
	echo export JRE_HOME=/usr/java/jdk1.8.0_191-amd64/jre >/etc/profile.d/javaenv.sh
	echo export PATH=$$PATH:/bin:/usr/java/jdk1.8.0_191-amd64/jre/bin >/etc/profile.d/javaenv.sh

.set-jdk8-envrc: ## Quick install of oracle jdk 8 for splice-sa req.
	echo export JAVA_HOME=/bin >> ~/.envrc
	echo export JRE_HOME=/usr/java/jdk1.8.0_191-amd64/jre >> ~/.envrc
	echo export PATH=$$PATH:/bin:/usr/java/jdk1.8.0_191-amd64/jre/bin >> ~/.envrc

.set-jdk8-bash: ## Quick install of oracle jdk 8 for splice-sa req.
	echo export JAVA_HOME=/bin >> ~/.bash_profile
	echo export JRE_HOME=/usr/java/jdk1.8.0_191-amd64/jre >> ~/.bash_profile
	echo export PATH="$${PATH:+$${PATH}:}/bin:/usr/java/jdk1.8.0_191-amd64/jre/bin" >> ~/.bash_profile

install-splice-sa-jdk8: .install-jdk8-linux .set-jdk8-envrc .set-jdk8-bash ## Installs jdk for centos
	@echo "Run the following: source ~/.bash_profile

install-splice-sa-requirements: ## Install centos splice-sa system requirements
	source "${HOME}/.bash_profile"
	yum -y install epel-release
	yum -y install curl nscd ntp openssh openssh-clients openssh-server patch rlwrap wget ftp nc maven
	sed -i '/requiretty/ s/^/#/' /etc/sudoers
	service nscd start
	systemctl enable nscd.service
	service ntpd start
	systemctl enable ntpd.service

.install-splice-sa-linux: ## Downloads splice-sa binary for the local account (Linux)
	wget --no-cookies --no-check-certificate "https://s3.amazonaws.com/splice-releases/2.7.0.1815/standalone/SPLICEMACHINE-2.7.0.1815.standalone.tar.gz"
	tar xzvf "SPLICEMACHINE-2.7.0.1815.standalone.tar.gz"
	@echo export PATH="$${PATH:+$${PATH}:}${HOME}/SPLICEMACHINE/bin" >> ~/.bash_profile
	@echo "Run the following: source ~/.bash_profile"

install-splice-engine: ## Installs splice engine
	git clone https://github.com/splicemachine/spliceengine.git

install-splice-sa-bash: ## Adds SPLICEMACHINE to local path
	@echo export PATH="$${PATH:+$${PATH}:}${HOME}/SPLICEMACHINE/bin" >> ~/.bash_profile
	@echo "Run the following: source ~/.bash_profile"

.install-splice-sa-windows: ## Downloads splice-sa binary for the local account (Windows)
	@echo 'not supported'

start-splicemachine: ## Startup splicemachine
	$(shell sh "${HOME}/splicemachine/bin/start-splice.sh" &)

start-zeppelin-container: ## Start up Apache zeppelin
	mkdir -p ./logs
	mkdir -p ./notebook
	docker run -d -p 8080:8080 --rm -v "${PWD}/logs:/logs" -v "${PWD}/notebook:/notebook" -e ZEPPELIN_LOG_DIR='/logs' -e ZEPPELIN_NOTEBOOK_DIR='/notebook' --name zeppelin apache/zeppelin:0.8.0

watch-zookeeper-log: ## Watch the zookeeper log output
	tail  /home/vagrant/splicemachine/log/zoo.log -f -n 25

install-zookeeper-notebooks: ## Install the splice notebooks
	git clone https://github.com/splicemachine/zeppelin-notebooks.git
	./zeppelin-notebooks/load-notebooks.py
