# Pulumi taskset
# Don't mess with the pulumi binpath, the official installer script 
# is hardcoded for it unfortunately.

PULUMI_BINPATH := ${HOME}/.pulumi/bin
INSTALL_PULUMI_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_PULUMI_TASK := .install-pulumi-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_PULUMI_TASK := .install-pulumi-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_PULUMI_TASK := .install-pulumi-windows
endif

install-pulumi: ## Downloads pulumi binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_PULUMI_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_PULUMI_TASK)

.install-pulumi-osx: ## Downloads and installs pulumi (OSX)
	@echo 'Installing pulumi utility'
	brew install pulumi

.install-pulumi-linux: ## Downloads pulumi binary for the local account (Linux)
	@echo 'Installing pulumi'
	curl -fsSL https://get.pulumi.com | sh
	@echo ''
	@echo 'Tip: Start a local only state cache (pulumi login --local)!'

.install-pulumi-windows: ## Downloads pulumi binary for the local account (Windows)
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://get.pulumi.com/install.ps1'))" && SET "PATH=%PATH%;%USERPROFILE%\.pulumi\bin"

initialize-pulumi: ## Initializes pulumi for this deployment
	@echo 'Setting up pulumi'
	$(PULUMI_BINPATH)/pulumi login --local