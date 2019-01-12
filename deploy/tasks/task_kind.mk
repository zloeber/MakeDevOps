## Kind installer and examples.

KIND_CLUSTER_NAME?=mdo
DEST?=./
INSTALL_kind_TASK:=.show-platform-error
kind_FOUND:=$(shell command -v $(BIN_PATH)/kind 2> /dev/null)

ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_kind_TASK := .install-kind-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_kind_TASK := .install-kind-linux
endif

install-kind: ## Downloads kind binary for the local account
	@echo 'Platform = $(HOST_PLATFORM)'
ifeq (,$(wildcard $(BIN_PATH)/kind))
	@echo 'Task = $(INSTALL_kind_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_kind_TASK)
else
	@echo "Task = ${BIN_PATH}/kind already installed!"
endif

.install-kind-osx: ## Downloads and installs kind (OSX)
	@echo 'Installing kind'
	brew install kind

.install-kind-linux: ## Downloads kind binary for the local account (Linux)
	@echo 'Installing kind'
	$(GOBIN)/go get sigs.k8s.io/kind

start-kind-session: ## Initializes k8s cluster, sets kubectl vars
	kind create cluster --name "${KIND_CLUSTER_NAME}"

export-kind-session: ## Exports KUBECONFIG to point to kind path
	export KUBECONFIG="$$(kind get kubeconfig-path --name="${KIND_CLUSTER_NAME}")"

stop-kind-session: ## Stops k8s cluster, resets kubectl vars
	kind delete cluster --name "${KIND_CLUSTER_NAME}"

add-kind-session-to-direnv: ## Adds current kind KUBECONFIG to .envrc
	@touch .direnv
	@echo 'export KUBECONFIG="$$(kind get kubeconfig-path --name="${KIND_CLUSTER_NAME}")"' >> $(DEST).direnv
	@direnv allow

show-kind-session: ## Shows kind export information
	@echo KUBECONFIG="$$(kind get kubeconfig-path --name="${KIND_CLUSTER_NAME}")"