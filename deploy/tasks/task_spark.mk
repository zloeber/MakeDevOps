## Replace spark with your tasks name and modify 
spark_BINPATH := ${HOME}/.local/bin
SPARK_VERSION?=2.4
INSTALL_spark_TASK := .show-platform-error
ifeq ($(HOST_PLATFORM),Darwin)  # Mac OS X
	INSTALL_spark_TASK := .install-spark-osx
endif
ifeq ($(HOST_PLATFORM),Linux)
	INSTALL_spark_TASK := .install-spark-linux
endif

install-spark: ## Downloads spark binary for the local account
	@echo 'Current platform = $(HOST_PLATFORM)'
	@echo 'Task = $(INSTALL_spark_TASK)'
	@$(MAKE) -s -C . scrt=$(scrt) dpl=$(dpl) $(INSTALL_spark_TASK)

.install-spark-osx: ## Downloads and installs spark (OSX)
	@echo 'Installing spark'
	brew install spark

.install-spark-linux: ## Downloads spark binary for the local account (Linux)
	@echo 'Installing spark'
	git clone -b branch-${SPARK_VERSION} https://github.com/apache/spark
	cd spark
	./build/mvn -Pkubernetes -DskipTests clean package

