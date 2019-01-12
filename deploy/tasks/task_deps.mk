# Determine host platform
ifeq ($(OS),Windows_NT)
	HOST_PLATFORM := Windows
else
	HOST_PLATFORM := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

INSTALL_DEPS_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_DEPS_TASK = .install-deps-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_DEPS_TASK = .install-deps-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_DEPS_TASK = .install-deps-windows
endif

APP_GOPATH = $(go env GOPATH | cut -d: -f1)

install-deps: ## Required to build, deploy, or publish this project
	@echo '** Install dependencies $(HOST_PLATFORM) **'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_DEPS_TASK)

.install-deps-osx: install-python-requirements ## Install build dependencies (OSX)
	@echo 'Installing xcode if required'
	xcode-select --install 2>/dev/null || true
	
	@echo 'Installing Homebrew if required'
	ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" 2>/dev/null || true
	
	@echo 'Running brew installs/updates'
	brew update
	brew uninstall awk 2>/dev/null || true
	brew install gettext gradle openssl gawk
	brew tap caskroom/versions
	brew cask install java8
	brew link gawk 2>/dev/null || true

.install-deps-linux: install-python-requirements ## Install build dependencies (OSX)

install-bash-autocompleters: ## Install autocomplete for a few commands
	@echo 'Adding bash completion to your profile'
	@echo 'source /etc/profile.d/bash_completion.sh' >> ${HOME}/.bashrc
	@echo 'Adding aws command line completion to your bash profile'
	@echo 'complete -C ${HOME}/.local/bin/aws_completer aws' >> ${HOME}/.bashrc

install-python-requirements: ## Install Python modules
	@echo 'Python requirements'
	@pip install -r $(PROJECT_DIR)/deploy/requirements.txt --user

.install-deps-windows: ## Install build dependencies (OSX)
	@echo 'Installing build dependencies (Windows)'