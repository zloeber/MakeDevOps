## Makefile for $(TASK_APP) utility operations
TASK_APP := kubicorn

# Determine host platform
ifeq ($(OS),Windows_NT)
	HOST_PLATFORM := Windows
else
	HOST_PLATFORM := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

INSTALL_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_TASK := .install-kubicorn-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_TASK := .install-kubicorn-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_TASK := .install-kubicorn-windows
endif

install-kubicorn: ## Downloads $(TASK_APP) binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_TASK)

.install-kubicorn-osx: ## Downloads and installs $(TASK_APP) (OSX)
	@echo 'Installing $(TASK_APP) utility'
	brew install $(TASK_APP)

.install-kubicorn-linux: ## Downloads kubicorn binary for the local account (Linux)
	@echo 'Installing go into userspace'
	export GOPATH=${HOME}/.local/bin/go
	#@rm -rf ${GOPATH}
	export GOPATH=${HOME}/.local/bin/go
	@mkdir -p ${GOPATH}
	$(GOBIN)/go get github.com/$(TASK_APP)/$(TASK_APP)
	echo '$(TASK_APP) install path: $$GOPATH/bin/$(TASK_APP)'

.install-kubicorn-windows: .show-platform-error ## Downloads $(TASK_APP) binary for the local account (Windows)
