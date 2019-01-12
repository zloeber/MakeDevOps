# These are more deops oriented tools (mostly just installations)
# If I do more than an install then I'll make another task file

INSTALL_PLANT_TASK := .show-platform-error
INSTALL_ENVMAN_TASK := .show-platform-error
INSTALL_BITRISE_TASK := .show-platform-error
INSTALL_CONFD_TASK := .show-platform-error
INSTALL_TERRAGRUNT_TASK := .show-platform-error
INSTALL_AWLESS_TASK := .show-platform-error
INSTALL_AWSVAULT_TASK := .show-platform-error
INSTALL_OPUNIT_TASK := .show-platform-error

ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_PLANT_TASK := .install-plant-osx
	INSTALL_BITRISE_TASK := .install-bitrise-osx
	INSTALL_ENVMAN_TASK := .install-envman-osx
	INSTALL_CONFD_TASK := .install-confd-unix
	INSTALL_TERRAGRUNT_TASK := .install-terragrunt-unix
	INSTALL_AWLESS_TASK := .install-awless-osx
	INSTALL_AWSVAULT_TASK := .install-awsvault-osx
	INSTALL_OPUNIT_TASK := .install-opunit-unix
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_PLANT_TASK := .install-plant-linux
	INSTALL_ENVMAN_TASK := .install-envman-linux
	INSTALL_CONFD_TASK := .install-confd-unix
	INSTALL_TERRAGRUNT_TASK := .install-terragrunt-unix
	INSTALL_AWLESS_TASK := .install-awless-linux
	INSTALL_AWSVAULT_TASK := .install-awsvault-linux
	INSTALL_OPUNIT_TASK := .install-opunit-unix
endif

BIN_DIR ?= ${HOME}/.local/bin
install-awless: ## Downloads awless binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_AWLESS_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_AWLESS_TASK)

install-awless-completers: # Configures tab completion for zsh/bash
	@echo 'source <(awless completion bash)' >> ${HOME}/.bashrc
	@echo 'source <(awless completion zsh)' >> ${HOME}/.zshrc

.install-awless-osx: ## Downloads and installs awless (OSX)
	@echo Installing awless binary
	brew tap wallix/awless
	brew install awless

.install-awless-linux: ## Downloads awless binary (Linux)
	@echo 'Installing awless binary'
	@curl https://raw.githubusercontent.com/wallix/awless/master/getawless.sh | bash
	@mv ./awless ${BIN_DIR}

install-opunit: ## Downloads awless binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_OPUNIT_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_OPUNIT_TASK)

.install-opunit-unix: ## Downloads and installs awless (*nix)
	@echo Installing opunit binary
	npm install -g opunit

install-awsvault: ## Downloads aws-vault binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_AWSVAULT_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_AWSVAULT_TASK)

.install-awsvault-osx: ## Downloads and installs aws-vault (OSX)
	@echo Installing aws-vault binary
	brew cask install aws-vault

.install-awsvault-linux: ## Downloads aws-vault binary (Linux)
	@echo 'Installing aws-vault binary (via go)'
	$(GOBIN)/go get github.com/99designs/aws-vault

install-plant: ## Downloads plant binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_PLANT_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_PLANT_TASK)

.install-plant-osx: ## Downloads and installs plant (OSX)
	@echo Installing plant binary
	@brew install plant

.install-plant-linux: ## Downloads plant binary for the local account (Linux)
	@echo 'Installing plant binary'
	@rm -rf ${BIN_DIR}/plant
	@mkdir -p ${BIN_DIR}
	curl -o ${BIN_DIR}/plant -fsSL 'https://raw.githubusercontent.com/theplant/plantbuild/master/plantbuild'
	@chmod +x ${BIN_DIR}/plant
	@echo 'Installed to: ${BIN_DIR}/plant'

install-terragrunt: ## Downloads plant binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_TERRAGRUNT_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_TERRAGRUNT_TASK)

.install-terragrunt-unix: ## Downloads and installs terragrunt
	$(SCRIPT_PATH)/install-local-bin.sh terragrunt  https://github.com/gruntwork-io/terragrunt/releases/download/v0.17.1/terragrunt_$$(uname -s)_amd64

install-envman: ## Downloads envman binary
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_ENVMAN_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_ENVMAN_TASK)

.install-envman-linux: ## Downloads envman binary for Linux
	$(SCRIPT_PATH)/install-github-release.sh bitrise-io/envman

.install-envman-osx: ## Downloads envman binary for OSX
	$(SCRIPT_PATH)/install-local-bin.sh envman https://github.com/bitrise-io/envman/releases/download/2.0.0/envman-$$(uname -s)-$$(uname -m)

.install-bitrise-osx: ## Downloads bitrise binary for OSX
	brew update && brew install bitrise

install-bitrise: ## Downloads plant binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_BITRISE_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_BITRISE_TASK)

install-confd: ## Downloads and installs confd
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_CONFD_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_CONFD_TASK)

.install-confd-unix: ## Downloads and installs confd (*nix)
ifndef GOPATH
endif
	@echo "GOPATH = $(GOPATH)"
	@rm -rf "$(GOPATH)/src/github.com/kelseyhightower"
	@mkdir -p ${GOPATH}/src/github.com/kelseyhightower
	git clone https://github.com/kelseyhightower/confd.git ${GOPATH}/src/github.com/kelseyhightower/confd
	@pushd ${GOPATH}/src/github.com/kelseyhightower/confd
	$(MAKE) -s -C ${GOPATH}/src/github.com/kelseyhightower/confd
	@rm -rf ${BIN_DIR}/confd
	@mkdir -p ${BIN_DIR}
	@cp ${GOPATH}/src/github.com/kelseyhightower/confd/bin/confd ${BIN_DIR}/confd
	@popd

install-linuxbrew: ## Installs linuxbrew for local user (requires password)
	$(SCRIPT_PATH)/install-local-bin.sh install-linuxbrew https://raw.githubusercontent.com/Linuxbrew/install/master/install.sh
	${BIN_DIR}/install-linuxbrew

install-pip: ## Installs latest version of pip for the local account
	@wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py -O - | python - --user

install-pyenv: ## Installs pyenv for the current account
	@echo "Installing pyenv to ${HOME}/.pyenv"
	@curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

install-pyenv-completers: ## Setup pyenv completers and path to profile
	@echo "Adding ${HOME}/.pyenv to .bashrc and .zshrc"
	@cat $(SCRIPT_PATH)/pyenv_init.sh >> "${HOME}/.bashrc"
	@cat $(SCRIPT_PATH)/pyenv_init.sh >> "${HOME}/.zshrc"