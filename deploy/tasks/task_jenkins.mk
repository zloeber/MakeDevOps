# Determine host platform
ifeq ($(OS),Windows_NT)
	HOST_PLATFORM := Windows
else
	HOST_PLATFORM := $(shell sh -c 'uname -s 2>/dev/null || echo not')
endif

INSTALL_BUTLER_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_BUTLER_TASK = install-butler-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_BUTLER_TASK = install-butler-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_BUTLER_TASK = install-butler-windows
endif

APP_GOPATH = $(go env GOPATH | cut -d: -f1)

get-jenkinscli: ## Download jenkins-cli from a deployment
	mkdir -p ${HOME}/.local/bin/
	@curl -o ${HOME}/.local/bin/jenkins-cli.jar
	@curl -o ${HOME}/.local/bin/butler -LO $(JENKINS_SERVER)/jnlpJars/jenkins-cli.jar
	@chmod +x ${HOME}/.local/bin/jenkins-cli.jar

install-butler: ## Downloads jenkinsx binary for the local account
	@echo 'Current platform - $(HOST_PLATFORM)'
	@echo 'Sub-task - $(INSTALL_BUTLER_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_BUTLER_TASK)

install-butler-osx: ## Installs jx binary for the local account (OSX)
	@mkdir -p ${HOME}/.local/bin/
	@rm -rf ${HOME}/.local/bin/butler
	@curl -o ${HOME}/.local/bin/butler -LO https://s3.us-east-1.amazonaws.com/butlercli/1.0.0/osx/butler
	@chmod +x ${HOME}/.local/bin/butler

install-butler-linux: ## Installs jx binary for the local account (Linux)
	@mkdir -p ${HOME}/.local/bin/
	@rm -rf ${HOME}/.local/bin/butler
	@curl -o ${HOME}/.local/bin/butler -LO https://s3.us-east-1.amazonaws.com/butlercli/1.0.0/linux/butler
	@chmod +x ${HOME}/.local/bin/butler

install-butler-windows: ## Installs jx binary for the local account (Windows)
	@mkdir -p ${HOME}/.local/bin/
	@rm -rf ${HOME}/.local/bin/butler
	@curl -o ${HOME}/.local/bin/butler -LO https://s3.us-east-1.amazonaws.com/butlercli/1.0.0/windows/butler
	@chmod +x ${HOME}/.local/bin/butler

## Jenkins job builder tasks
create-jjb-ini:	## Creates a local temporary jjb ini file to use
	@rm -rf /tmp/setup.ini
	@touch /tmp/setup.ini
	@echo '[jenkins]' >> /tmp/setup.ini
	@echo "url=$(JENKINS_SERVER)" >> /tmp/setup.ini
	@echo 'query_plugins_info=False' >> /tmp/setup.ini
	@echo 'Updated /tmp/setup/ini'

show-jjb-plugins: create-jjb-ini ## Show installed plugins
	jenkins-jobs --ignore-cache --user $(JENKINS_ADMIN_USER) --password $(JENKINS_ADMIN_PASS) --server jenkins --conf /tmp/setup.ini get-plugins-info

show-jjb-jobs: create-jjb-ini ## Shows all Jenkins jobs
	jenkins-jobs --ignore-cache --user $(JENKINS_ADMIN_USER) --password $(JENKINS_ADMIN_PASS) --server jenkins --conf /tmp/setup.ini list

delete-jjb-jobsall: create-jjb-ini ## Deletes ALL Jenkins jobs
	jenkins-jobs --ignore-cache --user $(JENKINS_ADMIN_USER) --password $(JENKINS_ADMIN_PASS) --server jenkins --conf /tmp/setup.ini delete-all

deploy-local-jenkins: ## Runs the Jenkins master locally
	@echo 'Starting $(PROJECT_NAME) in $(PROJECT_DIR) with $(dpl)'
	@cat $(dpl) | envsubst | docker-compose -f $(PROJECT_DIR)/$(COMPOSE_FILE) -p $(COMPOSE_PROJECT_NAME) up -d --build
	@export JENKINS_USER="$(JENKINS_ADMIN_USER)"
	@export JENKINS_PASS="$(JENKINS_ADMIN_PASS)"
	@export JENKINS_SERVER="$(JENKINS_SERVER)"

stop-local-jenkins: ## Stop and remove a running deployment
	@echo 'Shutting down compose project'
	docker-compose --project-directory $(PROJECT_DIR) -f $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME) down

show-local-jenkins-status: ## Show current status of local deployment
	docker-compose --project-directory $(PROJECT_DIR) -f $(COMPOSE_FILE) --project-name $(COMPOSE_PROJECT_NAME) ps


build-jenkinsmaster-repos: ## Builds ECR repo and pushes latest tagged versions of images
	@$(MAKE) -s -C $(PROJECT_DIR)/deploy/container cnf=jenkinsmaster.env dpl=deploy.env build-repo

build-jenkinsmaster-binaries: ## Build the Jenkins master binaries for docker images
	./gradlew packages

build-jenkinsmaster-images: ## Build images
	@$(MAKE) -s -C $(PROJECT_DIR)/deploy/container cnf=jenkinsmaster.env dpl=deploy.env build tag-latest

build-jenkinsmaster-images-nocache: ## Build images (no cache)
	@$(MAKE) -s -C $(PROJECT_DIR)/deploy/container cnf=jenkinsmaster.env dpl=deploy.env build-nc tag-latest

publish-jenkinsmaster-latest: ## Publish latest images to repo
	@$(MAKE) -s -C $(PROJECT_DIR)/deploy/container cnf=jenkinsmaster.env dpl=deploy.env publish-latest

publish-jenkinsmaster-all: ## Tags and publishes all images to their repective repo
	@$(MAKE) -s -C $(PROJECT_DIR)/deploy/container cnf=jenkinsmaster.env dpl=deploy.env publish

shell-local: ## Drop into a bash shell on jenkinsmaster
	docker exec -it $$(docker ps -aqf "name=jenkinsmaster") bash