kubectl_BINPATH ?= ${HOME}/.local/bin

INSTALL_KUBECTL_TASK := .show-platform-error

DESIRED_VERSION ?= latest 

ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_KUBECTL_TASK := .install-kubectl-windows
endif
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_KUBECTL_TASK := .show-platform-error
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_KUBECTL_TASK := .install-kubectl-linux
endif

install-kubectl: ## Downloads the kubectl binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Command = $(INSTALL_KUBECTL_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_KUBECTL_TASK)

.install-kubectl-windows: ## Downloads kubectl binary for the local account (Windows)
	@echo Installing kubectl binary using choco
	@choco install kubernetes-cli

.install-kubectl-linux: ## Downloads kubectl binary for the local account (Linux)
	@echo 'Installing kubectl binary version - ($(K8S_VERSION))'
	@mkdir -p ${kubectl_BINPATH}
	@rm -rf ${kubectl_BINPATH}/kubectl
	@wget https://storage.googleapis.com/kubernetes-release/release/$(K8S_VERSION)/bin/linux/amd64/kubectl -O ${kubectl_BINPATH}/kubectl
	@chmod +x ${kubectl_BINPATH}/kubectl

install-kubectl-autocomplete: ## Downloads the kubectl binary for the local account
	@echo "Adding autocomplete permanently to: ${HOME}/.*rc"
	@echo "source <(${kubectl_BINPATH}/kubectl completion bash) 2> /dev/null" >> "${HOME}/.bashrc"
	@echo "source <(${kubectl_BINPATH}/kubectl completion zsh) 2> /dev/null" >> "${HOME}/.zshrc"

.PHONY: install-helm
install-helm: ## Installs Tiller/Helm on current k8s context
	curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | bash
	helm init
	helm repo update
	kubectl create serviceaccount --namespace kube-system tiller
	kubectl create clusterrolebinding tiller-cluster-rule --clusterrole=cluster-admin --serviceaccount=kube-system:tiller
	kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'

.PHONY: install-local-registry
install-local-registry: ## Install docker-registry locally
	helm install --name=${PROJECT_NAME}-reg stable/docker-registry
	export POD_NAME=$(kubectl get pods --namespace default -l "app=docker-registry,release=makedevops-repo" -o jsonpath="{.items[0].metadata.name}")
	@echo "${POD_NAME}"

install-crictl: ## Install crictl k8s utility
	go get github.com/kubernetes-incubator/cri-tools/cmd/crictl

install-nfs-prov: ## Install k8s with local nfs storage provisioning
	@echo "Configuring NFS in k8s"
	kubectl apply -f "${SCRIPT_PATH}/nfs-rbac.yaml"
	kubectl apply -f "${SCRIPT_PATH}/nfs-storageclass.yaml"
	kubectl apply -f "${SCRIPT_PATH}/nfs-deployment.yaml"

	@echo "Making nfs-storage the default storage class"
	kubectl patch storageclass nfs-storage -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

install-kubectx: ## Install kubectx utility
	@mkdir -p "${BIN_PATH}"
	@git clone https://github.com/ahmetb/kubectx ${HOME}/.local/kubectx
	@ln -s ${HOME}/.local/kubectx/kubectx ${BIN_PATH}/kubectx
	@ln -s ${HOME}/kubectx/kubens ${BIN_PATH}/kubens
