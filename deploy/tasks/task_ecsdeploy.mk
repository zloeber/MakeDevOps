# Not really finished yet...
INSTALL_ECSDEPLOY_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_ECSDEPLOY_TASK := ecsdeploy-install-linux
endif

ecsdeploy-install: ## Downloads ecs-deploy binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Command = $(DEPLOY_KOPS_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_ECSDEPLOY_TASK)

ecsdeploy-install-linux: ## Downloads ecs-deploy binary for the local account (Linux)
	@echo 'Installing ecs-deploy binary'
	@mkdir -p ${HOME}/.local/bin/
	@rm -rf ${HOME}/.local/bin/ecs-deploy
	@wget -o ${HOME}/.local/bin/ecs-deploy curl -L https://github.com/in4it/ecs-deploy/releases/download/0.0.12/ecs-deploy-linux-amd64
	@chmod +x ${HOME}/.local/bin/ecs-deploy
	@mv /tmp/ecs-deploy ${HOME}/.local/bin/ecs-deploy

ecsdeploy-deploy: ## Use ecs-deploy to bootstrap the cluster
	export _SG_ID=$(aws --output json ec2 describe-security-groups --filters Name=group-name,Values=$(EC2_SG_NAME) | jq '.SecurityGroups[] | .GroupId' | tr -d '"')

	CMD_DEPLOY_ECSD = 'ecs-deploy --bootstrap --ecs-desired-size $(ECS_INSTANCE_SIZE) --ecs-max-size $(ECS_INSTANCE_SIZE) --ecs-min-size 0 --alb-security-groups ${_SG_ID} --cloudwatch-logs-enabled --cloudwatch-logs-prefix $(APP_TEAM) --cluster-name $(PROJECT_NAME) --ecs-security-groups $(EC2_SG_NAME) --ecs-subnets $(ECS_SUBNETS) --environment $(APP_ENV) --instance-type $(ECS_INSTANCE_TYPE) --key-name $(ECS_KEYPAIR) --loadbalancer-domain $(ECS_LOADBALANCED_DOMAIN) --profile $(AWS_PROFILE) --region $(AWS_DEFAULT_REGION)'

	@eval $(CMD_DEPLOY_ECSD)
