## Replace nodejs with your tasks name and modify 
nodejs_BINPATH := ${HOME}/.local/bin
INSTALL_nodejs_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_nodejs_TASK := .install-nodejs-osx
	PREFIX:=$(brew --prefix)
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_nodejs_TASK := .install-nodejs-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_nodejs_TASK := .install-nodejs-windows
endif

install-nodejs: ## Downloads nodejs binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_nodejs_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_nodejs_TASK)

install-npm: ## Downloads nodejs binary for the local account
	echo prefix = "${HOME}/.local" >> ~/.npmrc
	curl http://npmjs.org/install.sh | sh

.install-nodejs-osx: ## Downloads and installs nodejs (OSX)
	@echo 'Installing nodejs'
	brew install node

.install-nodejs-linux: ## Downloads nodejs binary for the local account (Linux)
	@echo 'Installing nodejs'
	@rm -rf /tmp/nodejs-install
	@mkdir -p /tmp/nodejs-install
	pushd /tmp/nodejs-install
	curl http://nodejs.org/dist/node-latest.tar.gz | tar xz --strip-components=1
	./configure --prefix="${HOME}/.local"
	make install
	popd

.install-nodejs-windows: ## Downloads nodejs binary for the local account (Windows)
	@"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -InputFormat None -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://get.nodejs.com/install.ps1'))" && SET "PATH=%PATH%;%USERPROFILE%\.nodejs\bin"

initialize-nodejs: ## Initializes nodejs for this deployment
	@echo 'Setting up nodejs'

get-nodejs-version: ## Show installed version of binary
	$(nodejs_BINPATH)/nodejs version
