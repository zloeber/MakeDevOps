## Replace azurecli with your tasks name and modify 
azurecli_BINPATH := ${HOME}/.local/bin
INSTALL_azurecli_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_azurecli_TASK := .install-azurecli-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_azurecli_TASK := .install-azurecli-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_azurecli_TASK := .install-azurecli-windows
endif

install-azurecli: ## Downloads azurecli binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_azurecli_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_azurecli_TASK)

.install-azurecli-osx: ## Downloads and installs azurecli (OSX)
	@echo 'Installing azurecli'
	brew install azurecli

.install-azurecli-linux: ## Downloads azurecli binary for the local account (Linux)
	@echo 'Installing azurecli'
	curl -L https://aka.ms/InstallAzureCli | bash

.install-azurecli-windows: ## Downloads azurecli binary for the local account (Windows)
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://get.azurecli.com/install.ps1'))" && SET "PATH=%PATH%;%USERPROFILE%\.azurecli\bin"

login-azure: ## Initializes azurecli for this deployment
	@az login
