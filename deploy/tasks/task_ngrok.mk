
## Replace ngrok with your tasks name and modify 
ngrok_BINPATH := ${HOME}/.local/bin
NGROK_AUTH_TOKEN ?=
INSTALL_ngrok_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_ngrok_TASK := .install-ngrok-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_ngrok_TASK := .install-ngrok-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_ngrok_TASK := .install-ngrok-windows
endif

install-ngrok: ## Downloads ngrok binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_ngrok_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_ngrok_TASK)

.install-ngrok-osx: ## Downloads and installs ngrok (OSX)
	@echo 'Installing ngrok'
	brew install ngrok

.install-ngrok-linux: ## Downloads ngrok binary for the local account (Linux)
	@echo 'Installing ngrok'
	curl -fsSL https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip > /tmp/ngrok.zip
	unzip /tmp/ngrok.zip
	mv -f ./ngrok $(ngrok_BINPATH)

initialize-ngrok: ## Initializes ngrok for this deployment
	@echo 'Setting up ngrok'
	$(ngrok_BINPATH)/ngrok authtoken "${NGROK_AUTH_TOKEN}"

start-ngrok: ## Starts ngrok server up on port 80
	$(ngrok_BINPATH)/ngrok http 80

get-ngrok-help: ## Show ngrok help
	$(ngrok_BINPATH)/ngrok help
