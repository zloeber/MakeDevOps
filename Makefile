## Makefile for bootstrap and deployment of this project
SHELL=/bin/bash
ENABLED_TASKS ?= devops direnv golang kubernetes kind istio draft jx dockercompose docker
ROOT_DIR := $(abspath $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST))))))
MAKEDEVOPS_PATH ?= $(ROOT_DIR)

export PROJECT_DIR= $(MAKEDEVOPS_PATH)
export SCRIPT_PATH=$(PROJECT_DIR)/deploy/scripts
export TEMPLATE_PATH=$(PROJECT_DIR)/deploy/templates

# Plain text secrets file (if being used, not recommended).
# You can change the default config with `make scrt="secrets.env" build`
scrt ?= $(PROJECT_DIR)/deploy/placeholder.env
include $(scrt)
export $(shell sed 's/=.*//' $(scrt))

# Deployment configuration settings
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= $(PROJECT_DIR)/deploy/deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

ifeq ($(OS),Windows_NT)
    HOST_PLATFORM := Windows
else
    HOST_PLATFORM := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

# Some sane defaults
VERSION ?= $(APP_VERSION)
GOROOT ?= ${HOME}/.go
GOPATH ?= ${HOME}
GOBIN ?= ${GOROOT}/bin
BINPATH ?= ${HOME}/.local/bin
BIN_PATH ?= ${BINPATH}
FORCE ?= false

# Use this to bypass most errors for various tasks
#NOERRORLAND ?= " 2>/dev/null || true"
NOERRORLAND ?=

## Generate taskset commands if TS env var exists
CMD_ENABLE_TASKSET :=
CMD_DISABLE_TASKSET :=
ifdef TS
CMD_ENABLE_TASKSET := "ln -sf $(PROJECT_DIR)/deploy/tasks/task_$(TS).mk $(PROJECT_DIR)/deploy/tasks/enabled/"
CMD_DISABLE_TASKSET := "rm -rf $(PROJECT_DIR)/deploy/tasks/enabled/task_$(TS).mk"
endif

DEFAULT_TASKS = $(addsuffix .mk, $(addprefix $(PROJECT_DIR)/deploy/tasks/task_, $(ENABLED_TASKS)))

## Additional task sets. Comment/uncomment to explore
## some other deployment task sets.
include $(PROJECT_DIR)/deploy/tasks/enabled/*.mk

# INCLUDES
# Adds additional makefile definitions to the existing path.
#.INCLUDE_DIRS: $(PROJECT_DIR)/deploy/tasks/enabled

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: config
config: ## Enables tasks defined in ENABLED_TASKS
	@for task in $(DEFAULT_TASKS); do \
		echo "Enabling taskset: $${task}"; \
		ln -sf $$task $(PROJECT_DIR)/deploy/tasks/enabled/ > /dev/null; \
	done

.PHONY: enable-taskset
enable-taskset: ## Enable taskset defined in TASKSET
	eval $(CMD_ENABLE_TASKSET)

.PHONY: disable-taskset
disable-taskset: ## Enable taskset defined in TASKSET
	eval $(CMD_DISABLE_TASKSET)

.PHONY: export-envvars
export-envvars: ## Sources the deploy.env file into this session
	set -o allexport
	. $(PROJECT_DIR)/deploy/scripts/export_env_vars.sh $(dpl)
	set +o allexport

.PHONY: show-taskset
show-taskset: ## Shows all availble task sets
	@echo 'All available or known task sets:'
	@echo '---------------------------------'
	ls -1 $(PROJECT_DIR)/deploy/tasks/task_*.mk
	echo "${str#$prefix}"
	@echo ''
	@echo 'To enable any of these:'
	@echo '  ln -sf $(PROJECT_DIR)/deploy/tasks/task_<name>.mk $(PROJECT_DIR)/deploy/tasks/enabled/'
	@echo 'Or:'
	@echo '  make enable-taskset TS=<name>'

PHONY: show-taskset-enabled
show-taskset-enabled: ## Shows enabled task sets
	@ls -1 $(PROJECT_DIR)/deploy/tasks/enabled/*.mk
	@echo ''
	@echo 'To disable any of these (links):'
	@echo '  make disable-taskset TS=<name>'

PHONY: clear-taskset
clear-taskset: ## Disables all enabled tasksets
	@rm -f $(PROJECT_DIR)/deploy/tasks/enabled/task_*.mk
	@echo 'Tasksets reset to default'

PHONY: show-env
show-env: ## Environment and build information
	@echo 'ROOT_DIR: $(ROOT_DIR)'
	@echo 'PROJECT_DIR: $(PROJECT_DIR)'
	@echo 'HOST_PLATFORM: $(HOST_PLATFORM)'
	@cat $(dpl) | less

PHONY: show-version
show-version: ## Output the current version
	@echo "MakeDevOps - $(VERSION)"

PHONY: reset-zsh
reset-zsh: ## Reset zsh shell configuration (WARNING!)
	@cp -rf $(TEMPLATE_PATH)/.z* "${HOME}"
	@cp -rf $(SCRIPT_PATH)/.z* "${HOME}"
	@echo 'Restart zsh to reset shell'

PHONY: reset-bash
reset-bash: ## Reset bash shell configuration (WARNING!)
	@cp -rf $(TEMPLATE_PATH)/.bash* "${HOME}"
	@echo 'Restart bash process for reset shell'

PHONY: config-bin-path
add-bin-path: ## Adds .local/bin path to profile
	@echo "Ensuring ${BINPATH} exists"
	@mkdir -p "${BINPATH}"
	@echo "Adding ${BINPATH} to PATH in .bashrc"
	@echo 'export PATH="${BINPATH}:$${PATH}"' >> "${HOME}/.bashrc"

## Hidden tasks
.show-platform-error: ## Shows that there is some issue with the platform for the chosen operation
	@echo 'Platform is not supported for this operation: $(HOST_PLATFORM)'