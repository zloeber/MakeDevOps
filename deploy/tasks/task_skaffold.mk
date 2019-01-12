## Makefile for skaffold utility operations

#ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
#export PROJECT_DIR=$(shell dirname $(ROOT_DIR))
TASK_APP := skaffold

# Determine host platform
ifeq ($(OS),Windows_NT)
	HOST_PLATFORM := Windows
else
	HOST_PLATFORM := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

INSTALL_SKAFFOLD_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_SKAFFOLD_TASK := .install-skaffold-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_SKAFFOLD_TASK := .install-skaffold-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_SKAFFOLD_TASK := .show-platform-error
endif

install-skaffold: install-golang ## Downloads binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_SKAFFOLD_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_SKAFFOLD_TASK)

.install-skaffold-osx: ## Downloads and installs binary (OSX)
	@echo 'Installing $(TASK_APP) utility'
	brew install $(TASK_APP)

.install-skaffold-linux: ## Downloads and installs binary (Linux)
	@echo 'Installing $(TASK_APP) utility'
	@mkdir -p ${HOME}/.local/bin/
	@rm -rf ${HOME}/.local/bin/$(TASK_APP)
	@curl -Lo ${HOME}/.local/bin/$(TASK_APP) https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
	chmod +x ${HOME}/.local/bin/$(TASK_APP)