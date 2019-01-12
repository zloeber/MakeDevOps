HOST_PLATFORM ?= linux

INSTALL_BOOTKUBE_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_BOOTKUBE_TASK := install-bootkube-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_BOOTKUBE_TASK := install-bootkube-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_BOOTKUBE_TASK := install-bootkube-windows
endif

APP_GOPATH := $(shell go env GOPATH | cut -d: -f1)

install-bootkube: ## Downloads bootkube binary for the local account
	@echo 'Current platform - $(HOST_PLATFORM)'
	@echo 'Sub-task - $(INSTALL_BOOTKUBE_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_BOOTKUBE_TASK)

install-bootkube-osx: ## Downloads and installs bootkube (OSX)
	@echo 'Installing bootkube utility'
	brew tap azure/bootkube
	brew install bootkube

install-bootkube-linux: ## Downloads bootkube binary for the local account (Linux)
	@echo 'Installing bootkube utility'
	@go get -u github.com/kubernetes-incubator/bootkube 2>/dev/null || true
	@$(MAKE) -C ${HOME}/go/src/github.com/kubernetes-incubator/bootkube clean all
	@rm -rf ${HOME}/.local/bin/bootkube
	@mv ${HOME}/go/src/github.com/kubernetes-incubator/bootkube/_output/bin/linux/bootkube ${HOME}/.local/bin/bootkube

initialize-bootkube-aws: ## Initializes aws requirements for bootkube deployment.
	@echo 'bootkube - Initializing AWS components'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) NOERRORLAND=" 2>/dev/null || true" create-aws-k8s-sg show-aws-k8s-sg-id

deploy-bootkube-local-single: ## Deploy a local k8s cluster for development
	@$(MAKE) -s -C ${APP_GOPATH}/src/github.com/kubernetes-incubator/bootkube clean-vm-single run-single conformance-single

deploy-bootkube-local-cluster: ## Deploy a local k8s cluster for development
	@$(MAKE) -s -C ${APP_GOPATH}/src/github.com/kubernetes-incubator/bootkube clean-vm-multi run-multi conformance-multi