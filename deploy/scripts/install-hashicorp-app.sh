#!/usr/bin/env bash
# file: hashi-app.sh
# author: Jess Robertson, CSIRO Mineral Resources
# date: March 2017
#
# description: Download and install Hashicorp products from their 
#   release server. Note that this assumes that Hashicorp doesn't change
#   their release URLS.
#
#   Requires gnupg and openssl (see `install_dependencies`)

# Configure how we're going to install
SRC_DIRECTORY=${SRC_DIRECTORY:=~/.local/src}
BIN_DIRECTORY=${BIN_DIRECTORY:=~/.local/bin}

# Logging function
log () {
	echo "[hashi-app] - $(date '+%Y/%m/%d %H:%M:%S') - $1: ${@:2}"
}

help() {
	echo "Usage: hashi-app COMMAND"
	echo ""
	echo "Download, verify and install Hashicorp products from their"
	echo "release server."
	echo ""
	echo "Binaries that can be installed include packer, terraform, "
	echo "consul, vault and nomad. See https://releases.hashi-app.com/"
	echo "for a full list."
	echo
	echo "To specify where the binaries get downloaded to, use the "
	echo "SRC_DIRECTORY environment variable. To set the folder that "
	echo "the binary is extracted to, use the BIN_DIRECTORY variable."
	echo ""
	echo "Commands:"
	echo ""
	echo "    get_version BINARY - get the available versions for BINARY."	
	echo "    install_dependencies - Use APT to install dependencies"
	echo "        required by this script"
	echo "    install BINARY VERSION [PLATFORM] - install the given "
	echo "        VERSION of BINARY for PLATFORM. PLATFORM is optional,"
	echo "        if not specified it defaults to 'linux_amd64'"
	echo ""
	echo "Examples:"
	echo ""
	echo "    $ hashi-app get_version packer"
	echo ""
	echo "gets the currently available version numbers for packer, one"
	echo "per line"
	echo ""
	echo "    $ hashi-app install terraform 0.7.0 darwin"
	echo ""
	echo "will install the MacOSX Terraform binary"
	echo ""
	echo "    $ hashi-app install terraform 0.7.0"
	echo ""
	echo "will install the Linux 64-bit binary of terraform"
}

# Quiet pushd/popd commands
pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}

# Install dependencies using apt
install_dependencies () {
	log "INFO" "Updating apt"
	sudo apt-get update

	log "INFO" "Installing hashi-app dependencies"
	sudo apt-get install unzip wget gnupg openssl ca-certificates libcap-dev
}

# Scrapes the Hashicorp release endpoint for valid versions
# Usage: ./hashi-app.sh get_version <prog_name>
get_version () {
	binary="$1"
	
	# Scrape HTML from release page for binary versions, which are 
	# given as ${binary}_<version>. We just use sed to extract.
	curl -s "https://releases.hashicorp.com/${binary}/" \
		| sed -n "s|.*${binary}_\([0-9\.]*\).*|\1|p"
}

# Downloads and installs binaries from Hashicorp
# Usage: ./hashi-app install <prog_name> <prog_version>
install () {
	binary="$1"
	version="$2"
	platform="${3:-linux_amd64}"
	
	# Construct URL and zipfile name
	zipfile="${binary}_${version}_${platform}.zip"
	shasums="${binary}_${version}_SHA256SUMS"
	sigfile="${binary}_${version}_SHA256SUMS.sig"
	declare -a files=(${zipfile} ${shasums} ${sigfile})
	url="https://releases.hashicorp.com/${binary}/${version}"
	
	# Clean up existing binaries and provisioners
	log "INFO" "Cleaning up existing versions of ${binary}"
	declare -a directs=(${SRC_DIRECTORY} ${BIN_DIRECTORY})
	for dir in ${directs[@]}; do
		if [ ! -d "${dir}" ]; then
			log "DEBUG" "Couldn't find ${dir}, making it now"
			mkdir -p "${dir}"
		fi
	done
	rm -f ${BIN_DIRECTORY}/${binary}*

	# Download and install
	pushd ${SRC_DIRECTORY}
	for file in ${files[@]}; do
		log "DEBUG" "Downloading ${file} from ${url}"
		curl -s -O ${url}/${file}
	done
	unzip "${zipfile}"
        chmod +x ${binary}
        mv ${binary} ${BIN_DIRECTORY}/.
        log "INFO" "Extracted ${binary} to ${BIN_DIRECTORY}."
	
popd
}

# Run the command if we're not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	if [ -z "$1" ]; then 
		help
		exit
	fi
	$*
fi
