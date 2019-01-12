INSTALL_ISTIO_TASK := .show-platform-error

ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_ISTIO_TASK := .show-platform-error
endif
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_ISTIO_TASK := .install-istio-unix
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_ISTIO_TASK := .install-istio-unix
endif

install-istio-client: ## Downloads the isio binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Command = $(INSTALL_ISTIO_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_ISTIO_TASK)

.install-istio-unix: ## Downloads latest istio binary (Darwin/Linux)
	@echo 'Installing istio binary'
	$(SCRIPT_PATH)/install-istio.sh ${BIN_PATH} isio
	export PATH="${PATH}:${BIN_PATH}/isio/bin"
	echo 'export PATH="${PATH}:${BIN_PATH}/isio/bin"'

install-istio-chart: ## Attempts to use helm and a local chart to install istio
	helm install "${BIN_PATH}/isio/install/kubernetes/helm/istio" --name istio --namespace istio-system

add-istio-topath: ## Adds istio bin to current shell profiles
	echo 'export PATH="$$PATH:${BIN_PATH}/isio/bin"' >> ~/.bashrc
	echo 'export PATH="$$PATH:${BIN_PATH}/isio/bin"' >> ~/.zshrc