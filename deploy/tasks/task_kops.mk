INSTALL_KOPS_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_KOPS_TASK := install-kops-windows
endif
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_KOPS_TASK := install-kops-mac
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_KOPS_TASK := install-kops-linux
endif

install-kops: ## Downloads and configures kops binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Command = $(INSTALL_KOPS_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_KOPS_TASK)

install-kops-windows: ## Installs kops on windows
	@echo 'Figure it out here: https://github.com/kubernetes/kops'

install-kops-mac: ## Installs kops on mac
	@echo 'Installing kops binary'
	brew update && brew install kops

install-kops-linux: ## Installs kops on linux
	@mkdir -p ${HOME}/.local/bin/
	@rm -rf ${HOME}/.local/bin/kops
	@curl -o ${HOME}/.local/bin/kops -LO https://github.com/kubernetes/kops/releases/download/$$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
	@chmod +x ${HOME}/.local/bin/kops

deploy-kops: ## Deploys kubernetes cluster via kops and EC2
	@echo 'Deploying kubernetes via kops...'
	kops update cluster --name=$(KOPS_CLUSTER_URI) $(KOPS_ALLOW_AWS_DEPLOY) $(NOERRORLAND)

deploy-kops-route53: ## Creates AWS Route53 zones
	@echo 'Deploying AWS Route53 zone in AWS: $(KOPS_ROUTE53_ZONE)'
	aws route53 create-hosted-zone --name $(KOPS_ROUTE53_ZONE) --caller-reference 1 $(NOERRORLAND)
	@echo 'Adding appropriate tags'
	aws route53 change-tags-for-resource --resource-type hostedzone --resource-id Z1523434445 --remove-tag-keys owner

deploy-kops-statestore: ## Creates an s3 bucket for kops state store
	aws s3 mb $(KOPS_STATE_STORE) $(NOERRORLAND)

deploy-kops-aws-group: ## Deploy dedicated kops role group managing kops deployments
	@echo 'Deployment of kops AWS role group and policy'
	aws iam create-group --group-name $(KOPS_AWS_DEPLOY_GROUP) $(NOERRORLAND)
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $(KOPS_AWS_DEPLOY_GROUP) $(NOERRORLAND)
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $(KOPS_AWS_DEPLOY_GROUP) $(NOERRORLAND)
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $(KOPS_AWS_DEPLOY_GROUP) $(NOERRORLAND)
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $(KOPS_AWS_DEPLOY_GROUP) $(NOERRORLAND)
	aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $(KOPS_AWS_DEPLOY_GROUP) $(NOERRORLAND)

deploy-kops-aws-user: ## Deploy dedicated aws kops deployment user account
	@echo 'Deployment of kops AWS user'
	aws iam create-user --user-name $(KOPS_AWS_DEPLOY_USER) $(NOERRORLAND)
	aws iam add-user-to-group --user-name $(KOPS_AWS_DEPLOY_USER) --group-name $(KOPS_AWS_DEPLOY_GROUP) $(NOERRORLAND)
	aws iam create-access-key --user-name $(KOPS_AWS_DEPLOY_USER) $(NOERRORLAND)

deploy-kops-cluster-config: ## Deploy the kops cluster configuration to the state store
	@echo 'Staging kops configuration for cluster: $(KOPS_CLUSTER_URI)'
	kops create cluster --zones=$(KOPS_CLUSTER_ZONES) --name=$(KOPS_CLUSTER_URI) --node-count=$(ECS_INSTANCE_SIZE) --cloud-labels="CostCenter=$(APP_COST_CENTER), ApplicationName=$(APP_TEAM)" --state=$(KOPS_STATE_STORE) $(NOERRORLAND) --kubernetes-version=$(K8S_VERSION) --vpc $(K8S_VPC_NAME)

show-kops-cluster: ## Shows a kops cluster configuration
	@echo 'Describing the kops kubernetes configuration: $(KOPS_CLUSTER_URI)'
	kops get cluster --name=$(KOPS_CLUSTER_URI) $(NOERRORLAND)

show-kops-route53: ## Displays information about existing route53 domain
	@echo 'Describing AWS Route53 zone in AWS: $(KOPS_ROUTE53_ZONE)'
	aws route53 list-hosted-zones-by-name --dns-name $(KOPS_ROUTE53_ZONE) $(NOERRORLAND)

show-kops-statestore: ## Describes s3 bucket for kops state store
	aws s3 ls $(KOPS_STATE_STORE) $(NOERRORLAND)

show-kops-aws-group: ## Show information about the kops deployment group
	@echo 'Description of deployed kops AWS group'
	aws iam get-group --group-name $(KOPS_AWS_DEPLOY_GROUP)

show-kops-aws-user: ## Show information about the kops deployment user
	@echo 'Description of deployed kops AWS user'
	aws iam get-user --user-name $(KOPS_AWS_DEPLOY_USER)

update-kops-cluster: ## Deploy the kops cluster configuration to the state store if it has changed
	@echo 'Updating kops cluster if required: $(KOPS_CLUSTER_URI)'
	kops update cluster --name=$(KOPS_CLUSTER_URI) $(NOERRORLAND)

upgrade-kops-cluster: ## Deploy the kops cluster configuration to the state store if it has changed
	@echo 'Upgrading kops cluster: $(KOPS_CLUSTER_URI)'
	kops upgrade cluster --name=$(KOPS_CLUSTER_URI) $(NOERRORLAND)

edit-kops-cluster: ## Edit a kops cluster configuration
	@echo 'Editing kops cluster: $(KOPS_CLUSTER_URI)'
	kops edit cluster --name=$(KOPS_CLUSTER_URI) --state=$(KOPS_STATE_STORE) $(NOERRORLAND)

edit-kops-nodes: ## Edit nodes in a kops cluster
	@echo 'Editing your node instance group'
	kops edit ig --name=$(KOPS_CLUSTER_URI) --state=$(KOPS_STATE_STORE) nodes $(NOERRORLAND)

edit-kops-master: ## Edit master group in a kops cluster
	@echo 'Edit your master instance group: master-$(K8S_CLUSTER_NAME)'
	kops edit ig --name=$(KOPS_CLUSTER_URI) --state=$(KOPS_STATE_STORE) master-$(K8S_CLUSTER_NAME) $(NOERRORLAND)

validate-kops-cluster: ## Run a validation against a deployed cluster
	kops validate cluster --name=$(KOPS_CLUSTER_URI) --state=$(KOPS_STATE_STORE)

ssh-kops-master: ## Attempt to ssh to the master k8s node
	@echo 'Attemptin to ssh to $(KOPS_CLUSTER_API_URI)'
	ssh -i ~/.ssh/id_rsa admin@$(KOPS_CLUSTER_API_URI)
