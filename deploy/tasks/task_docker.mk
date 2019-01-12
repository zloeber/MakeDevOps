INSTALL_DOCKER_TASK := .show-platform-error

export DOCKER_HOST_IP=$(shell hostname)

ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_DOCKER_TASK := .install-docker-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_DOCKER_TASK := .install-docker-linux
endif

clean-docker: ## Prunes docker of unused resources (Use At Own Risk!)
	@docker network prune
	@docker system prune

install-notary: ## Install the notary cli
	$(SCRIPT_PATH)/deploy/scripts/install-github-release.sh theupdateframework/notary

#create-compose-manifest: ## Creates a docker-compose.yml manifest based on env vars (example only)
#	@rm -rf docker-compose.yml
#	@envsubst < "docker-compose-template.yml" > "docker-compose-manifest.yml"