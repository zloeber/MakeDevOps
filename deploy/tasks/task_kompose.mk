
INSTALL_KOMPOSE_TASK := .show-platform-error

ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_KOMPOSE_TASK := .install-kompose-windows
endif
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_KOMPOSE_TASK := .install-kompose-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_KOMPOSE_TASK := .install-kompose-linux
endif

install-kompose: ## Downloads kompose binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_KOMPOSE_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_KOMPOSE_TASK)

KOMPOSE_VERSION := $(echo `curl -L -s -H 'Accept: application/json' https://github.com/kubernetes/kompose/releases/latest` | sed -e 's/.*"tag_name":"\([^"]*\)".*/\1/')

.install-kompose-windows: ## Downloads and installs kompose (Windows)
	@choco install kubernetes-kompose

.install-kompose-osx: ## Downloads and installs kompose (OSX)
	@echo Installing kompose binary
	@brew install kompose

.install-kompose-linux: ## Downloads kompose binary for the local account (Linux)
	@echo 'Installing kompose binary'
	@echo ' - Latest Version: $(KOMPOSE_VERSION)'
	@echo ''
	@rm -rf ${HOME}/.local/bin/kompose
	@mkdir -p ${HOME}/.local/bin
	curl -o ${HOME}/.local/bin/kompose -L 'https://github.com/kubernetes/kompose/releases/download/$(KOMPOSE_VERSION)/kompose-linux-amd64'
	@chmod +x ${HOME}/.local/bin/kompose
