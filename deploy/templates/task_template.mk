## Replace taskname with your tasks name and modify 
taskname_BINPATH := ${HOME}/.local/bin
INSTALL_taskname_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_taskname_TASK := .install-taskname-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_taskname_TASK := .install-taskname-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_taskname_TASK := .install-taskname-windows
endif

install-taskname: ## Downloads taskname binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_taskname_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_taskname_TASK)

.install-taskname-osx: ## Downloads and installs taskname (OSX)
	@echo 'Installing taskname'
	brew install taskname

.install-taskname-linux: ## Downloads taskname binary for the local account (Linux)
	@echo 'Installing taskname'
	curl -fsSL https://get.taskname.com | sh

.install-taskname-windows: ## Downloads taskname binary for the local account (Windows)
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://get.taskname.com/install.ps1'))" && SET "PATH=%PATH%;%USERPROFILE%\.taskname\bin"

initialize-taskname: ## Initializes taskname for this deployment
	@echo 'Setting up taskname'

get-taskname-version: ## Show installed version of binary
	$(taskname_BINPATH)/taskname version
