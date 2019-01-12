
INSTALL_ANSIBLE_TASK := .show-platform-error

ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_ANSIBLE_TASK := .install-ansible-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_ANSIBLE_TASK := .install-ansible-linux
endif

install-ansible: ## Downloads ansible binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_ANSIBLE_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_ANSIBLE_TASK)

.install-ansible-osx: ## Downloads and installs ansible (OSX)
	@echo Installing ansible binary
	@brew install ansible

.install-ansible-linux: ## Downloads and installs ansible (Linux)
	@echo Installing ansible binary
	@pip install ansible -U --user

ansible-create-cfg: ## Drops a standard local ansible configuration file
	@rm -rf $(ANSIBLE_PATH)/custom_ansible_filter_plugins
	@mkdir -p $(ANSIBLE_PATH)/custom_ansible_filter_plugins
	@cp -rp $(SCRIPT_PATH)/ansible/custom_ansible_filter_plugins/* $(ANSIBLE_PATH)/custom_ansible_filter_plugins/

	@rm -rf $(ANSIBLE_PATH)/custom_ansible_modules
	@mkdir -p $(ANSIBLE_PATH)/custom_ansible_modules
	@cp -rp $(SCRIPT_PATH)/ansible/custom_ansible_modules/* $(ANSIBLE_PATH)/custom_ansible_modules/

	@rm -rf $(ANSIBLE_PATH)/custom_ansible_action_plugins
	@mkdir -p $(ANSIBLE_PATH)/custom_ansible_action_plugins
	@cp -rp $(SCRIPT_PATH)/ansible/custom_ansible_action_plugins/* $(ANSIBLE_PATH)/custom_ansible_action_plugins/

	@rm -rf $(ANSIBLE_CONFIG)
	@envsubst < "$(SCRIPT_PATH)/ansible/ansible.cfg" > "$(ANSIBLE_CONFIG)"
	@echo "Ansible Configuration Export: export ANSIBLE_CONFIG=$(ANSIBLE_CONFIG)"

ansible-create-local-cfg: ## Drops a configuration file to the local path
	@rm -rf ansible.cfg
	@envsubst < "$(SCRIPT_PATH)/ansible/ansible.cfg" > ansible.cfg
	@echo "Created ansible.cfg in the current folder"

## install-ansiblecontainer: ## Downloads and installs ansible-container for docker.
##	virtualenv ansible-container
##	source ansible-container/bin/activate
##	pip install ansible-container --user

install-ansible-awx: ## Downloads and installs awx (tower) locally to docker
	rm -rf /tmp/awx-server/
	mkdir -p /tmp/awx-server
	@echo 'Copying in a port override (8052)..'
	cp "$(SCRIPT_PATH)/ansible/docker-compose.awx.local.yml" /tmp/awx-server/
	cd /tmp/awx-server
	@echo 'Downloading docker-compose.yml for awx to /tmp/awx-server/docker-compose.yml'
	$(SCRIPT_PATH)/from-web-to-dir.sh 'https://raw.githubusercontent.com/geerlingguy/awx-container/master/docker-compose.yml' /tmp/awx-server
	@echo 'Starting awx docker-compose project'
	docker-compose -f /tmp/awx-server/docker-compose.yml -f /tmp/awx-server/docker-compose.awx.local.yml -d up

	##pushd /tmp
	##git clone https://github.com/ansible/awx.git
	##git clone https://github.com/ansible/awx-logos.git
	
install-ansible-extras: ## Installs a few extra modules for ansible exploration
	pip install ansible-container ansible-docutizer ansible-shell ansible-toolkit ansible-docgenerator ansible-docgen ansible-review ansible-discover ansible-roles-graph --user
