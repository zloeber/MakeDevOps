## Draft tasks
DRAFT_INSTALL_URL := https://azuredraft.blob.core.windows.net/draft/draft-v0.16.0-linux-amd64.tar.gz

INSTALL_DRAFT_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_DRAFT_TASK := .install-draft-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_DRAFT_TASK := .install-draft-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_DRAFT_TASK := .install-draft-windows
endif

install-draft: ## Downloads draft binary for the local account
	@echo 'Platform = $(HOST_PLATFORM)'
ifeq (,$(wildcard $(BIN_PATH)/draft))
	@echo 'Task = $(INSTALL_DRAFT_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_DRAFT_TASK)
else
	@echo "Task = ${BIN_PATH}/draft already installed!"
endif

.install-draft-osx: ## Downloads and installs draft (OSX)
	@echo 'Installing draft utility'
	brew tap azure/draft
	brew install draft

.install-draft-linux: ## Downloads draft binary for the local account (Linux)
	"${SCRIPT_PATH}/install-local-bin.sh" "${DRAFT_INSTALL_URL}" "draft" "${BIN_PATH}" "linux-amd64/"
	#@echo 'Creating draft alias to container'
	#alias draft='docker run --rm quay.io/kontena/draft:latest'

.install-draft-windows: .show-platform-error ## Downloads draft binary for the local account (Windows)

.initialize-draft: ## Initializes draft for this deployment
	@echo 'Setting draft container registry
	draft init
	draft config set registry ${DRAFT_REGISTRY_URL}
