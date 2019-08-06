
INSTALL_TERRAFORM_TASK := .show-platform-error

TF_LATEST ?= $(shell $(SCRIPT_PATH)/hashi-app.sh get_version terraform | sed -n 2p)

ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_TERRAFORM_TASK := .install-terraform-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_TERRAFORM_TASK := .install-terraform-linux
endif

install-terraform: ## Downloads terraform binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_TERRAFORM_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_TERRAFORM_TASK)

.install-terraform-osx: ## Downloads and installs terraform (OSX)
	@echo Installing terraform binary
	brew install terraform
	## Optionally
	## $(SCRIPT_PATH)/hashi-app.sh install terraform 0.12.00 darwin

.install-terraform-linux: ## Downloads and installs terraform (Linux)
	@echo "Installing terraform latest: $(TF_LATEST)"
	$(SCRIPT_PATH)/install-hashicorp-app.sh install terraform 0.11.11

tf-create-project-tree: ## Creates a standard tf folder structure suitable for AWS projects in this directory.
	## Stage
	@mkdir -p stage/vpc
	@mkdir -p stage/services
	@mkdir -p stage/data-storage
	## Prod
	@mkdir -p prod/vpc
	@mkdir -p prod/services
	@mkdir -p prod/data-storage
	## Mgmt
	@mkdir -p mgmt/vpc
	@mkdir -p mgmt/services/jenkins
	@mkdir -p mgmt/services/bastion-host
	## Global
	@mkdir -p global/iam
	@mkdir -p global/route53

docker-create-aws-tfstate: ## Creates terraform state files for the existing aws environment
	mkdir -p ./terraforming-output
	docker run --rm --name terraforming -v ${HOME}/.aws/credentials:/root/.aws/credentials quay.io/dtan4/terraforming:latest terraforming ec2 --profile $(AWS_PROFILE) --tfstate
