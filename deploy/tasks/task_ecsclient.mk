INSTALL_ECSCLIENT_TASK := .show-platform-error

ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_ECSCLIENT_TASK := .show-platform-error
endif
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_ECSCLIENT_TASK := .show-platform-error
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_ECSCLIENT_TASK := install-ecsclient-linux
endif

install-ecsclient: ## Downloads ecs-client binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Command = $(INSTALL_ECSCLIENT_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_ECSCLIENT_TASK)

install-ecsclient-linux: ## Downloads ecs-client binary for the local account (Linux)
	@echo 'Installing ecs-client binary (Linux)'
	@mkdir -p ${HOME}/.local/bin/
	@wget https://github.com/in4it/ecs-deploy/releases/download/0.0.12/ecs-client-linux-amd64 -O /tmp/ecs-client
	@chmod +x /tmp/ecs-client
	@rm -rf ${HOME}/.local/bin/ecs-client
	@mv /tmp/ecs-client ${HOME}/.local/bin/ecs-client