INSTALL_MORTAR_TASK := .show-platform-error

ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_MORTAR_TASK := .install-mortar-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_MORTAR_TASK := .install-mortar-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_MORTAR_TASK := .install-mortar-windows
endif


install-mortar: ## Downloads mortar binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_MORTAR_TASK)'
	@$(MAKE) -s -C . cnf=$(cnf) dpl=$(dpl) $(INSTALL_MORTAR_TASK)

.install-mortar-osx: ## Downloads and installs mortar (OSX)
	@echo 'Installing mortar container'
	@docker pull quay.io/kontena/mortar:latest
	@echo 'Creating mortar alias'
	@alias mortar='docker run --rm quay.io/kontena/mortar:latest'

.install-mortar-linux: ## Downloads mortar binary for the local account (Linux)
	@echo 'Installing mortar container'
	@alias mortar='docker run --rm quay.io/kontena/mortar:latest'
	@echo 'Creating mortar alias'
	@alias mortar='docker run --rm quay.io/kontena/mortar:latest'

.install-mortar-windows: .show-platform-error ## Downloads mortar binary for the local account (Windows)
