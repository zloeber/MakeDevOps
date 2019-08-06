## Direnv - Manage your local env vars with style
direnv_BINPATH := ${HOME}/.local/bin
INSTALL_direnv_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_direnv_TASK := .install-direnv-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_direnv_TASK := .install-direnv-linux
endif
ifeq ($(HOST_PLATFORM),Windows)
	INSTALL_direnv_TASK := .install-direnv-windows
endif

install-direnv-hooks: ## Setup direnv hooks in current profiles
	@echo 'eval "$$($(BIN_PATH)/direnv hook zsh)"' >> "${HOME}/.zshrc"
	@echo 'source <($(BIN_PATH)/direnv hook bash)' >> "${HOME}/.bashrc"

install-direnv: ## Downloads direnv binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_direnv_TASK)'
	$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_direnv_TASK)

.install-direnv-linux: ## Downloads and installs direnv (Linux)
	$(SCRIPT_PATH)/install-github-release.sh direnv/direnv ${direnv_BINPATH} direnv linux-amd64

.install-direnv-osx: ## Downloads and installs direnv (osx)
	$(SCRIPT_PATH)/install-github-release.sh direnv/direnv ${direnv_BINPATH} direnv darwin-amd64

set-direnv-for-pyenv: ## Creates file needed to use pyenv with direnv
	@echo "Adding to ${HOME}/.direnvrc"
	@cat $(TEMPLATE_PATH)/direnv_pyenv.sh >> "${HOME}/.direnvrc"

PYVER?=3.7.2
DEST?="${PWD}"

new-direnv-pyenv-envrc: ## Create a .envrc file for a pyenv managed Python project
	@cp -f $(TEMPLATE_PATH)/envrc-python "${DEST}/.envrc"