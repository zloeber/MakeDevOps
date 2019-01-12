ROOT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

export PROJECT_DIR=$(shell dirname $(ROOT_DIR))

DEPLOY_ECSCLI_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Linux)
	DEPLOY_ECSCLI_TASK := install-ecscli-linux
endif

install-ecscli: ## Downloads ecs-cli binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Command = $(DEPLOY_ECSCLI_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(DEPLOY_ECSCLI_TASK)

install-ecscli-linux: ## Downloads ecs-cli binary for the local account (Linux)
	@echo Installing ecs-cli binary
	@mkdir -p ${HOME}/.local/bin/
	@curl -o /tmp/ecs-cli https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest
	@chmod +x /tmp/ecs-cli
	@rm -rf ${HOME}/.local/bin/ecs-cli
	@mv /tmp/ecs-cli ${HOME}/.local/bin/ecs-cli

deploy-ecscli-config: ## Sets up an appropriate ecs-cli profile
	@echo 'Deployment of ECR Cluster Profile: $(ECS_CLUSTER_NAME)'
	ecs-cli configure --cluster $(ECS_CLUSTER_NAME) --region $(AWS_DEFAULT_REGION) --default-launch-type $(ECS_TYPE) --config-name $(PROJECT_NAME) $(NOERRORLAND)

deploy-ecscli-sg:  ## Deploys the ecs security group $(EC2_SG_NAME)
	aws ec2 create-security-group --group-name $(EC2_SG_NAME) --description "$(EC2_SG_NAME) Security Group" --vpc-id $(ECS_VPC_NAME) $(NOERRORLAND)

deploy-ecscli: ecs-deploy-config deploy-aws-keypair deploy-ecscli-sg ## Deploys or updates ecs from compose file
	ecs-cli up --keypair $(ECS_KEYPAIR) --capability-iam --size $(ECS_INSTANCE_SIZE) --instance-type $(ECS_INSTANCE_TYPE) --cluster-config $(PROJECT_NAME) --vpc $(ECS_VPC_NAME) --subnets $(ECS_SUBNETS) --force --aws-profile $(AWS_PROFILE) $(NOERRORLAND)

deploy-ecscli-force: deploy-ecscli-config deploy-aws-keypair deploy-ecscli-sg ## Deploys or updates a deployment
	ecs-cli up --keypair $(ECS_KEYPAIR) --capability-iam --size $(ECS_INSTANCE_SIZE) --instance-type $(ECS_INSTANCE_TYPE) --cluster-config $(PROJECT_NAME) --vpc $(ECS_VPC_NAME) --subnets $(ECS_SUBNETS) --force --aws-profile $(AWS_PROFILE) $(NOERRORLAND)

delete-ecscli-cluster: ## Destroys existing deployment
	@echo 'Destruction of ECR Cluster: $(PROJECT_NAME)'
	ecs-cli down --cluster $(ECS_CLUSTER_NAME) --region $(AWS_DEFAULT_REGION) --cluster-config $(PROJECT_NAME) --aws-profile $(AWS_PROFILE) --force $(NOERRORLAND)

deploy-ecscli-ecsparams: ## Creates ecs-params.yml based on your env files.
	@echo 'Creating/Updating ecs-cli param file: $(PROJECT_PATH)/ecs-params.yml'
	@touch $(PROJECT_PATH)/ecs-params.yml
	@echo 'version: 1' > $(PROJECT_PATH)/ecs-params.yml
	@echo 'task_definition:' >> $(PROJECT_PATH)/ecs-params.yml
	@echo '  ecs_network_mode: awsvpc' >> $(PROJECT_PATH)/ecs-params.yml
	@echo 'run_params:' >> $(PROJECT_PATH)/ecs-params.yml
	@echo '  network_configuration:' >> $(PROJECT_PATH)/ecs-params.yml
	@echo '	awsvpc_configuration:' >> $(PROJECT_PATH)/ecs-params.yml
	@echo '	  subnets:' >> $(PROJECT_PATH)/ecs-params.yml
	@echo '		- $(ECS_INT_SUBNET1)' >> $(PROJECT_PATH)/ecs-params.yml
	@echo '		- $(ECS_INT_SUBNET2)' >> $(PROJECT_PATH)/ecs-params.yml
	@echo '	  security_groups:' >> $(PROJECT_PATH)/ecs-params.yml
	@echo '		- $(ECS_SG_NAME)' >> $(PROJECT_PATH)/ecs-params.yml

initialize-ecscli: deploy-ecscli-ecsparams ## Initializes the ecs-params.yml file

ecscli: initialize-ecscli ## Attempts to build the entire project via ecs-cli
	@echo 'Attempting to deploy via ecs-cli...'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) NOERRORLAND=" 2>/dev/null || true" deploy-ecscli
