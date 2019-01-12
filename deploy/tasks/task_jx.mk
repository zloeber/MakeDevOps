# JenkinsX installer and examples.

#REQUIRED_BINS := go kubectl
#$(foreach bin,$(REQUIRED_BINS),\
#    $(if $(shell command -v $(bin) 2> /dev/null),,$(error Please install `$(bin)`)))

jx_BINPATH := ${HOME}/.local/bin
jx_FOUND := $(shell command -v jx 2> /dev/null)
jx_AUTOCOMPLETE:=source <(${jx_BINPATH}/jx completion bash)

# Determine host platform
ifeq ($(OS),Windows_NT)
	HOST_PLATFORM := Windows
else
	HOST_PLATFORM := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

INSTALL_JENKINSX_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_JENKINSX_TASK = .install-jx-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_JENKINSX_TASK = .install-jx-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_JENKINSX_TASK = .install-jx-windows
endif

APP_GOPATH = $(go env GOPATH | cut -d: -f1)
install-jx: install-jenkinsx ## Downloads jx binary for the local account
install-jenkinsx: ## Downloads jx binary for the local account
	@echo 'Current platform - $(HOST_PLATFORM)'
	@echo 'Sub-task - $(INSTALL_JENKINSX_TASK)'
ifndef jx_FOUND
	@echo 'jx not found in path, installing..'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_JENKINSX_TASK)
endif

install-jx-completer: ## Adds jx tab completion to current bash profile
	@echo "${jx_AUTOCOMPLETE}" >> "${HOME}/.bashrc"

.install-jx-osx: ## Installs jx binary for the local account (OSX)
	@echo 'Installing jenkinsx utility'
	brew tap jenkins-x/jx
	brew install jx

.install-jx-linux: ## Installs jx binary for the local account (Linux)
	@echo 'Installing jenkinsx utility'
	$(SCRIPT_PATH)/install-github-release.sh jenkins-x/jx

.install-jx-windows: ## Installs jx binary for the local account (Windows)
	choco install jenkins-x
	choco upgrade jenkins-x

deploy-jx-k8s-aws: ## Jenkinsx - Deploy k8s cluster to AWS ec2 instances
	@echo 'Jenkinsx - Deploy Kubernetes cluster to aws (via kops)'
	jx create cluster aws

deploy-jx-k8s-eks: ## Jenkinsx - Deploy k8s cluster to AWS EKS cluster
	@echo 'Jenkinsx - Deploy Kubernetes cluster to AWS eks'
	jx create cluster eks

deploy-jx-k8s-aks: ## Jenkinsx - Deploy k8s cluster to Azure AKS cluser
	@echo 'Jenkinsx - Deploy Kubernetes cluster to Azure AKS'
	jx create cluster aks

deploy-jx-k8s-oke: ## Jenkinsx - Deploy k8s cluster to OKE
	@echo 'Jenkinsx - Deploy Kubernetes cluster to Oracle OKE'
	jx create cluster oke

deploy-jx-k8s-minikube: ## Jenkinsx - Deploy k8s cluster to local minikube
	@echo 'Jenkinsx - Deploy Kubernetes cluster to local minikube'
	jx create cluster minikube

deploy-jx-k8s-minishift: ## Jenkinsx - Deploy k8s cluster to local minishift
	@echo 'Jenkinsx - Deploy Kubernetes cluster to local minishift'
	jx create cluster minishift

start-jx-console: ## Jenkinsx - Launch the console
	jx console