GOLANG_BINPATH := ${HOME}/.local/bin
GOLANG_FOUND := $(shell command -v go 2> /dev/null)

INSTALL_GOLANG_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_GOLANG_TASK := .install-golang-linux
endif
ifeq ($(HOST_PLATFORM),Darwin)
	INSTALL_GOLANG_TASK := .install-golang-osx
endif

install-golang: ## Downloads the golang binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Command = $(INSTALL_GOLANG_TASK)'
ifndef GOLANG_FOUND
	@echo 'go not found in path, installing..'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_GOLANG_TASK)
endif

.install-golang-osx: ## Installs golang binary for the local account (OSX)
	@echo 'Installing Golang'
	brew install golang

.install-golang-linux: ## Installs golang to the userspace
	@echo 'Installing Golang'
	@rm -rf ${GOLANG_BINPATH}/goinstall.sh
	@mkdir -p ${GOLANG_BINPATH}
	curl -o ${GOLANG_BINPATH}/goinstall -L https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh
	@chmod +x ${GOLANG_BINPATH}/goinstall
	${GOLANG_BINPATH}/goinstall --64 2>/dev/null || true