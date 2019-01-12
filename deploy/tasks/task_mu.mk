## Makefile for mu utility operations

#ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
#export PROJECT_DIR=$(shell dirname $(ROOT_DIR))
TASK_APP := mu

# Determine host platform
ifeq ($(OS),Windows_NT)
	HOST_PLATFORM := Windows
else
	HOST_PLATFORM := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

INSTALL_MU_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_MU_TASK := .install-mu-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_MU_TASK := .install-mu-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_MU_TASK := .show-platform-error
endif

install-mu: install-golang ## Downloads binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Running install task: $(INSTALL_MU_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_MU_TASK)

.install-mu-osx: ## Downloads and installs binary (OSX)
	@echo 'Installing $(TASK_APP) binary'
	brew tap stelligent/tap
	brew install $(TASK_APP)-cli

.install-mu-linux: ## Downloads and installs binary (Linux)
	@echo 'Installing $(TASK_APP) binary'
	@rm -rf ${HOME}/.local/bin/$(TASK_APP)
	@mkdir -p ${HOME}/.local/bin/
	curl -s https://getmu.io/install.sh | INSTALL_DIR=${HOME}/.local/bin/ sh
