# import config.
# You can change the default config with `make cnf="centos.env" build`
cnf ?= config.env
-include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

# import deploy config
# You can change the default deploy config with `make cnf="deploy_special.env" release`
dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# grep the version from the version script
VERSION ?= $(APP_VERSION)

## HELPERS
CMD_AWS_PASSTHROUGH :=
# generate script to login to aws docker repo
ifdef AWS_CLI_PROFILE
CMD_AWS_PASSTHROUGH += " --profile $(AWS_CLI_PROFILE)"
endif
ifdef AWS_CLI_REGION
CMD_AWS_PASSTHROUGH += " --region $(AWS_CLI_REGION)"
endif

CMD_SSOLOGIN := "python ./aws-sso.py $(CMD_AWS_PASSTHROUGH)"
CMD_REPOLOGIN := "eval $$\( aws ecr get-login --no-include-email \)"
CMD_ECR_CREATE := "aws ecr create-repository --repository-name $(ECR_REPO_NAME) 2>/dev/null || true"
CMD_ECR_DESCRIBE := "aws ecr describe-repositories --repository-name $(ECR_REPO_NAME) | jq '.repositories[0].repositoryUri'"

.PHONY: help clean-docker build build-nc run up shell stop release publish publish-latest publish-version publish-environment tag tag-latest tag-version tag-environment sso-login repo-login version install-deps build-repo describe-repo

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

# DOCKER TASKS
clean-docker: ## Prunes docker of unused resources (Use At Own Risk!)
	docker network prune
	docker system prune
	@echo "Done"

build: ## Build the container
	@docker build -t $(APP_NAME) $(APP_PATH)
	@echo "Built image $(APP_NAME)"

build-nc: ## Build the container (no caching)
	docker build --no-cache -t $(APP_NAME) $(APP_PATH)
	@echo "Built image $(APP_NAME)"

run: ## Run bash into container
	docker run -it --rm --env-file=./config.env --name="$(APP_NAME)" "$(APP_NAME):latest" /bin/bash

up: build run ## Build then run the container

shell: run ## Drop into a bash shell in this container

stop: ## Stop and remove a running container
	docker stop $(APP_NAME); docker rm $(APP_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` and `latest` tagged containers to ECR

# Docker publish
publish: repo-login publish-latest publish-version publish-environment ## Publish the `{version}` and `latest` tagged containers to ECR

publish-latest: tag-latest ## Publish the latest tagged container
	@echo "Publishing $(ECR_URI)/$(ECR_REPO_NAME) - latest"
	docker push $(ECR_URI)/$(ECR_REPO_NAME):latest

publish-version: tag-version ## Publish the `{version}` tagged container
	@echo "Publishing $(ECR_URI)/$(ECR_REPO_NAME) - $(VERSION)"
	docker push $(ECR_URI)/$(ECR_REPO_NAME):$(VERSION)

publish-environment: tag-version ## Publish the `{APP_ENV}` tagged container
	@echo "Publishing $(ECR_URI)/$(ECR_REPO_NAME) - $(VERSION)"
	docker push $(ECR_URI)/$(ECR_REPO_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version tag-environment ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container latest tag
	@echo "Create tag - latest"
	docker tag $(APP_NAME) $(ECR_REPO_NAME):latest
	docker tag $(APP_NAME):latest $(ECR_URI)/$(ECR_REPO_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo "create tag $(VERSION)"
	docker tag $(APP_NAME) $(ECR_REPO_NAME):$(VERSION)
	docker tag $(APP_NAME):$(VERSION) $(ECR_URI)/$(ECR_REPO_NAME):$(VERSION)

tag-environment:
	@echo "create tag $(APP_ENV)"
	docker tag $(APP_NAME) $(ECR_REPO_NAME):$(APP_ENV)
	docker tag $(APP_NAME):$(APP_ENV) $(ECR_URI)/$(ECR_REPO_NAME):$(APP_ENV)

sso-login: install-deps ## Login to aws via sso to sts.nielsen.com
	@eval $(CMD_SSOLOGIN)

# login to AWS-ECR
repo-login: ## Auto login to AWS-ECR unsing aws-cli
	@eval $(CMD_REPOLOGIN)

version: ## Output the current version
	@echo $(VERSION)

install-deps: ## Install modules required to build or publish this project
	pip install -r requirements.txt --user
	@echo 'Build dependencies have been installed'

build-repo: ## Create an ECR repo for this container
	eval $(CMD_ECR_CREATE)

describe-repo: ## Describe an ECR repo for $(ECR_REPO_NAME)
	eval $(CMD_ECR_DESCRIBE)
