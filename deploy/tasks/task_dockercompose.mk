HOST_PLATFORM ?= linux
INSTALL_DOCKERCOMPOSE_TASK := .show-platform-error

ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_DOCKERCOMPOSE_TASK := .install-dockercompose-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_DOCKERCOMPOSE_TASK := .install-dockercompose-linux
endif

install-dockercompose: ## Downloads docker-compose binary for the local account
	@echo 'Current platform - $(HOST_PLATFORM)'
	@echo 'Command - $(INSTALL_DOCKERCOMPOSE_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_DOCKERCOMPOSE_TASK)

.install-dockercompose-linux: ## docker-compose binary and autocomplete for bash
	@echo "Setting up docker-compose"
	@curl  -L https://github.com/docker/compose/releases/download/$$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)/docker-compose-`uname -s`-`uname -m` > /tmp/docker-compose
	@chmod +x /tmp/docker-compose
	@rm -rf ${HOME}/.local/bin/docker-compose
	@mv /tmp/docker-compose ${HOME}/.local/bin/docker-compose

install-dockercompose-bash: ## Installs docker autocomplete for bash
	@echo "Setting up docker-compose cli autocompletion"
	@curl -L https://raw.githubusercontent.com/docker/compose/$$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)/contrib/completion/bash/docker-compose > /tmp/docker-compose.comp
	@rm -rf ${HOME}/.local/bin/docker-compose.comp
	@cp /tmp/docker-compose.comp ${HOME}/.local/bin/docker-compose.comp
	## @echo 'complete -C ${HOME}/.local/bin/docker-compose.comp docker-compose' >> ${HOME}/.bashrc
	@sudo mkdir -p /etc/bash_completion.d	
	@sudo mv /tmp/docker-compose.comp /etc/bash_completion.d/docker-compose
