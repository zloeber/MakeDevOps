## Replace gcloud with your tasks name and modify 
gcloud_BINPATH := ${HOME}/.local/bin
INSTALL_gcloud_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_gcloud_TASK := .install-gcloud-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_gcloud_TASK := .install-gcloud-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_gcloud_TASK := .install-gcloud-windows
endif

install-gcloud: ## starts gcloud installer
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_gcloud_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_gcloud_TASK)

.install-gcloud-osx: ## Downloads and installs gcloud (OSX)
	@echo 'Installing gcloud'
	brew install gcloud

.install-gcloud-linux: ## Downloads gcloud binary for the local account (Linux)
	@echo 'Installing gcloud'
	curl https://sdk.cloud.google.com | bash