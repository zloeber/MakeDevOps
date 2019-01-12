## hugo static site generator tasks

hugo_BINPATH := ${HOME}/.local/bin
INSTALL_hugo_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_hugo_TASK := .install-hugo-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_hugo_TASK := .install-hugo-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_hugo_TASK := .install-hugo-windows
endif

install-hugo: ## Downloads hugo binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_hugo_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_hugo_TASK)

.install-hugo-osx: ## Downloads and installs hugo (OSX)
	@echo 'Installing hugo'
	brew install hugo

.install-hugo-linux: ## Downloads hugo binary for the local account (Linux)
	@echo 'Installing hugo'
	$(SCRIPT_PATH)/install-hugo-latest.sh

.install-hugo-windows: ## Downloads hugo binary for the local account (Linux)
	@echo 'Installing hugo'
	choco install hugo --confirm

install-hugow: ## Setup hugow wrapper utility
	@echo 'Setting up hugow'
	curl -L -o hugow https://github.com/khos2ow/hugo-wrapper/releases/download/v1.2.0/hugow && chmod +x hugow
	./hugow --upgrade
