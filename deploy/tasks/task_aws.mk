HOST_PLATFORM ?= linux

## HELPERS
CMD_AWS_PASSTHROUGH :=

# generate script to login to aws docker repo
ifdef AWS_PROFILE
CMD_AWS_PASSTHROUGH += " --profile $(AWS_PROFILE)"
endif
ifdef AWS_DEFAULT_REGION
CMD_AWS_PASSTHROUGH += " --region $(AWS_DEFAULT_REGION)"
endif

CMD_ECR_CREATE := "aws ecr create-repository --repository-name $(AWS_REPO_NAME) $(NOERRORLAND)"
CMD_ECR_DESCRIBE := "aws ecr describe-repositories --repository-name $(AWS_REPO_NAME) | jq '.repositories[0].repositoryUri'"
CMD_REPOLOGIN := "eval $$\( aws ecr get-login --no-include-email \)"
CMD_SSOLOGIN := "python $(PROJECT_DIR)/deploy/scripts/aws-sso.py $(CMD_AWS_PASSTHROUGH)"

create-aws-kms: ## Deploys a kms key to use with deployments
	@echo Deploying new kms $(AWS_KMS_NAME) if you have the permission...
	aws kms create-key --key-usage ENCRYPT_DECRYPT --description $(AWS_KMS_NAME) --tags TagKey=CostCenter,TagValue=$(APP_COST_CENTER)

create-aws-keypair: ## Creates an AWS key pair for your deployment
	@echo Deploying new EC2 key pair $(ECS_KEYPAIR)
	aws ec2 create-key-pair --key-name $(ECS_KEYPAIR) --query 'KeyMaterial' --output text > $(ECS_KEYPAIR)-key.pem $(NOERRORLAND)
	chmod 400 $(ECS_KEYPAIR)-key.pem

create-aws-ecs-iam: ## Applies required ECS IAM roles for deploy operations
	@echo "Deploying iam role $(ECS_IAM_ROLE)"
	aws iam create-role --role-name $(ECS_IAM_ROLE) --assume-role-policy-document file://task-execution-assume-role.json $(NOERRORLAND)

	@echo "Attaching iam role policy $(ECS_IAM_ROLEPOLICY)"
	aws iam attach-role-policy --role-name $(ECS_IAM_ROLEPOLICY) --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy $(NOERRORLAND)

create-aws-k8s-sg: ## Creates k8s aws security group
	@echo 'Creating/Updating k8s security group: $(K8S_AWS_SECGROUP)'
	aws ec2 create-security-group --group-name $(K8S_AWS_SECGROUP) --description "Security group for K8s cluster $(K8S_CLUSTER_NAME)" --vpc-id $(AWS_DEFAULT_VPC) $(NOERRORLAND)
	@echo 'Authorizing port 22 to security group: $(K8S_AWS_SECGROUP)'
	aws ec2 authorize-security-group-ingress --group-name $(K8S_AWS_SECGROUP) --protocol tcp --port 22 --cidr 0.0.0.0/0 --vpc-id $(AWS_DEFAULT_VPC) $(NOERRORLAND)
	@echo 'Authorizing port 6443 to security group: $(K8S_AWS_SECGROUP)'
	aws ec2 authorize-security-group-ingress --group-name $(K8S_AWS_SECGROUP) --protocol tcp --port 6443 --cidr 0.0.0.0/0 --vpc-id $(AWS_DEFAULT_VPC) $(NOERRORLAND)
	@echo 'Authorizing all ports within security group: $(K8S_AWS_SECGROUP)'
	aws ec2 authorize-security-group-ingress --group-name $(K8S_AWS_SECGROUP) --protocol tcp --port 0-65535 --source-group $(K8S_AWS_SECGROUP) --vpc-id $(AWS_DEFAULT_VPC) $(NOERRORLAND)

create-aws-alb:	create-aws-ecs-sg ## Deploy application load balancer
	@echo 'Deployment of Application Load Balancer: $(ECS_ALB_NAME)'
	export _SG_ID=$$(aws --output json ec2 describe-security-groups --filters Name=group-name,Values=$(ECS_SG_NAME) | jq '.SecurityGroups[] | .GroupId' | tr -d '"')
	@echo "Security group id: ${_SG_ID}"

	aws elbv2 create-load-balancer --name $(ECS_ALB_NAME) --subnets $(ECS_SUBNETS) --security-groups $(_SG_ID) $(NOERRORLAND)

	@echo 'Application Load Balancer Target Group: $(ECS_ALB_TARGETGROUP)'
	aws elbv2 create-target-group --name $(ECS_ALB_TARGETGROUP) --protocol HTTP --port 80 --vpc-id $(ECS_VPC_NAME) $(NOERRORLAND)

	@echo 'Application Load Balancer Register Target Group'
	aws elbv2 register-targets --target-group-arn $(aws elbv2 describe-target-groups --name $(ECS_ALB_TARGETGROUP) | jq '.TargetGroups[0] | .TargetGroupArn' | tr -d '"') $(NOERRORLAND)

	#aws elbv2 register-targets --target-group-arn targetgroup-arn --targets Id=i-12345678 Id=i-23456789

create-aws-cfstack: ## Creates the deployment via Cloudformation stacks
	aws cloudformation create-stack --stack-name $(AWS_CFSTACK_NAME) --template-body file://cf_jenkins_stack.json $(NOERRORLAND)
	#--parameters ParameterKey=CostCenter,ParameterValue=$() ParameterKey=Parm2,ParameterValue=test2

create-aws-k8s-volume: ## Creates a volume for persistent data
	aws ec2 create-volume --encrypted --availability-zone us-east-1a --volume-type gp2 --size $(AWS_VOLUME_SIZE) --tag-specifications 'ResourceType=volume,Tags=[$(AWS_TAGS),{Key=VolumeName,Value=$(PROJECT_NAME)-vol1}]' $(NOERRORLAND)

show-aws-k8s-volume: ## Shows a created volume for persistent data
	aws ec2 describe-volumes --filter 'Name=tag:VolumeName,Values=$(PROJECT_NAME)-vol1' $(NOERRORLAND)

show-aws-k8s-volume-id: ## Shows AWS K8S volume id only
	aws --output json ec2 describe-volumes --filter 'Name=tag:VolumeName,Values=$(PROJECT_NAME)-vol1' $(NOERRORLAND) | jq '.Volumes[] | .VolumeId' | tr -d '"'

show-aws-alg: ## Describes ALG info
	@echo 'Application Load Balancer: $(ECS_ALB_NAME)'
	aws elbv2 describe-load-balancers --name $(ECS_ALB_NAME) $(NOERRORLAND)

	@echo 'Application Load Balancer Target Group: $(ECS_ALB_TARGETGROUP)'
	aws elbv2 describe-target-groups --name $(ECS_ALB_TARGETGROUP) $(NOERRORLAND)

	@echo Application Load Balancer Target Group Health
	aws elbv2 describe-target-health --target-group-arn $(aws --profile saml elbv2 describe-target-groups --name $(ECS_ALB_TARGETGROUP) | jq '.TargetGroups[0] | .TargetGroupArn' | tr -d '"')

show-aws-ecs-sg: ## Descibes security group $(ECS_SG_NAME) if it exists
	@echo "Security Group: $(ECS_SG_NAME)"
	aws ec2 describe-security-groups --filters Name=group-name,Values=$(ECS_SG_NAME) $(NOERRORLAND)

show-aws-k8s-sg: ## Shows AWS K8s security group
	@echo 'Security Group: $(K8S_AWS_SECGROUP)'
	aws ec2 describe-security-groups --filters Name=group-name,Values=$(K8S_AWS_SECGROUP) $(NOERRORLAND)

show-aws-k8s-sg-id: ## Shows AWS K8S security group id only
	aws --output json ec2 describe-security-groups --filters Name=group-name,Values=$(K8S_AWS_SECGROUP) | jq '.SecurityGroups[] | .GroupId' | tr -d '"'

show-aws-ecs-cluster: ## Shows information about a cluster you may have created
	@echo 'AWS ECS Cluster: $(ECS_CLUSTER_NAME)'
	aws ecs describe-clusters --clusters $(ECS_CLUSTER_NAME) $(NOERRORLAND)

show-aws-ecs-instances: ## Shows information about a containers you may have created
	@echo 'AWS ECS Cluster: $(ECS_CLUSTER_NAME)'
	@echo '$(ECS_CLUSTER_NAME) Container Instances:'
	aws ecs list-container-instances --cluster $(ECS_CLUSTER_NAME) $(NOERRORLAND)

show-aws-ecs-iam: ## Shows IAM information
	@echo Looking for IAM Role: $(ECS_IAM_ROLE)
	aws iam get-role --role-name $(ECS_IAM_ROLE) $(NOERRORLAND)
	@echo Looking for IAM Role Policy: $(ECS_IAM_ROLEPOLICY)
	aws iam get-role-policy --role-name $(ECS_IAM_ROLEPOLICY) $(NOERRORLAND)

show-aws-keypair: ## Lists aws key-pair information
	aws ec2 describe-key-pairs --key-name $(ECS_KEYPAIR) $(NOERRORLAND)

show-aws-ec2-internetgateway: ## Displays ECS Internet Gateway
	@echo "Looking for EC2 Internet Gateway: $(EC2_INTERNET_GATEWAY)"
	aws ec2 describe-internet-gateways --internet-gateway-ids $(EC2_INTERNET_GATEWAY) $(NOERRORLAND)

show-aws-cfstack: ## Displays AWS CloudFormation stack name for this project
	aws cloudformation describe-stacks --stack-name $(AWS_CFSTACK_NAME) $(NOERRORLAND)

show-aws-cfstack-all: ## Displays all AWS CloudFormation stack status
	aws cloudformation list-stacks | jq '.StackSummaries[] | .StackName + " - " + .StackStatus' $(NOERRORLAND)

show-aws-repos: ## Describes ECR Repos for this project
	@$(MAKE) -s -C ./container cnf=jenkinsmaster.env dpl=deploy.env describe-repo

show-aws-kms: ## Describe a kms key to use with deployments
	@echo KMS Info for $(AWS_KMS_NAME)
	#aws kms list-keys --query $(NOERRORLAND)

show-aws-ec2-sg-instances: ## Shows project security group instance associations
	aws ec2 describe-instances --query "Reservations[*].Instances[*].{ STATE:State.Name, VPC:VpcId, INSTANCE:InstanceId, \"SECURITY-ID\":SecurityGroups[0].GroupId, \"SECURITY-GROUP\":SecurityGroups[0].GroupName, SUBNET:SubnetId }" $(NOERRORLAND)

show-aws-ecs-all: ## Shows instances for all regions in your tennant (be careful!)
	for region in `aws ec2 describe-regions --output text | cut -f3` ; do \
		echo -e "\nListing Instances in region: $$region..." ; \
		aws ec2 describe-instances --region $$region ; \
	done

get-aws-ecsopt-recent-ami: ## Shows latest 3 ecs-optimized ami images for your region
	@echo 'Showing latest 3 ecs-optimized AMI images for region - $(AWS_DEFAULT_REGION)'
	aws ec2 describe-images --owner amazon --filters Name=name,Values=*amazon-ecs-optimized* --query 'Images[*].[ImageId,CreationDate,Name,Description]' --output text $(NOERRORLAND) | sort -rk2 | head -n3

get-aws-ecsopt-latest-ami: ## Shows latest ecs-optimized ami image id for your region
	aws ec2 describe-images --owner amazon --filters Name=name,Values=*amazon-ecs-optimized* --query 'Images[*].[ImageId,CreationDate,Name,Description]' --output text $(NOERRORLAND) | sort -rk2 | head -n1 | cut -f1

get-aws-coreos-latest-ami: ## Shows latest coreOS ami for your region
	curl -s https://coreos.com/dist/aws/aws-stable.json | jq -r '."$(AWS_DEFAULT_REGION)".hvm'

get-aws-amazonlinux-latest-ami: ## Shows latest Amazon Linux ami for your region
	aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2 --region us-east-1 --profile saml

delete-aws-keypair: ## Attempts to destroy $(ECS_KEYPAIR)
	@echo Removing keypair $(ECS_KEYPAIR) if possible...
	aws ec2 delete-key-pair --key-name $(ECS_KEYPAIR) $(NOERRORLAND)

delete-aws-ecs-sg: ## Attempts to destroy $(ECS_SG_NAME)
	@echo "Security Group: $(ECS_SG_NAME)"
	aws ec2 delete-security-group --filters Name=group-name,Values=$(ECS_SG_NAME) $(NOERRORLAND)

delete-aws-cfstack: ## Destroys CloudFormation stack name for this project
	@echo 'Attempting to delete cloudformation stack: $(AWS_CFSTACK_NAME)'
	aws cloudformation delete-stacks --stack-name $(AWS_CFSTACK_NAME) $(NOERRORLAND)

load-aws-ssm-params: ## Pull in SSM_<NAME> variables from parameter store
	@echo 'Loading SSM parameter store path: $(AWS_SSM_PS_PATH)'
	. ./scripts/entrypoint-from-ssm-env-vars.sh

add-aws-ssm-params: ## Add $(AWS_SSM_PS_PATH)/SSM_<NAME> variables to parameter store
	@echo 'Adding SSM parameter store path: $(AWS_SSM_PS_PATH)'
	. ./scripts/entrypoint-from-ssm-env-vars.sh

aws-sso-login: ## Update local authentication token for AWS via SSO
	eval $(CMD_SSOLOGIN)
	@export local_id=`aws configure get aws_access_key_id`
	@export local_key=`aws configure get aws_secret_access_key`
	@export local_token=`aws configure get aws_session_token`
	@export AWS_ACCESS_KEY_ID=`aws configure get aws_access_key_id`
	@export AWS_SECRET_ACCESS_KEY=`aws configure get aws_secret_access_key`
	@export AWS_SESSION_TOKEN=`aws configure get aws_session_token`

.PHONY repo-login
repo-login: ## Auto login to AWS-ECR unsing aws-cli
	eval $(CMD_REPOLOGIN)