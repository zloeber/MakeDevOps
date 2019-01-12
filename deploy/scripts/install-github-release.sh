#!/bin/bash
# Scrape github releases for most recent download of a project file
# Attempt to download and either extract/install or just install the
# binary within. Good for self contained golang or other well thought
# out utilities.
#
# Example
#   install-github-release.sh jenkins-x/jx "${HOME}/.local/bin" jx
# or just:
#   install-github-release.sh jenkins-x/jx
#
# Author: Zachary Loeber

# Quiet pushd/popd commands
pushd () {
    command pushd "$@" > /dev/null
}
popd () {
    command popd "$@" > /dev/null
}

function get_download_url {
	wget -q -nv -O- https://api.github.com/repos/$1/releases/latest 2>/dev/null | jq -r '.assets[] | select(.browser_download_url | contains("inux-amd64")) | .browser_download_url'
}

function install_binary {
    # 1 = source download link
    # 2 = destination folder
    # 3 = destination binary name
    echo "Download and install ${3} binary to ${2}"
    rm -rf "${2}/${3}"
    mkdir -p "${2}"
    curl -o "${2}/${3}" -fsSL ${1}
    chmod +x "${2}/${3}"
}

function install_targz {
    echo "Download, extract, and install ${3} binary to ${2}"
    pushd /tmp
    TAR="${3}.tar.gz"
	URL="${1}"
    FILE=$(basename $URL)

    rm -rf $TAR
	wget -q -nv -O $TAR $URL
	if [ ! -f $TAR ]; then
		echo "Cannot download $FILE from $URL"
        popd
		exit 1
	fi

    # Extract to target directory
    mkdir -p "${2}" >/dev/null
    rm -rf "${2}/${3}"
    tar -xzvf $TAR -C "${2}" >/dev/null
    popd
}

function install_targz_folder {
    # 1 = URL
    # 2 = Destination (ie. ~/.local/jdk8)
    URL="${1}"
    FILE=$(basename $URL)
    APP="${FILE%.tar.gz}"
    pushd /tmp
    2 = ${2?"${HOME}/.local/${APP}"}


    rm -rf $FILE
	wget -q -nv -O $TAR $URL
	if [ ! -f $FILE ]; then
		echo "Cannot download $FILE from $URL"
        popd
		exit 1
	fi

    # Extract to target directory
    mkdir -p "${2}"
    rm -rf "${2}/${3}"
    tar -xzvf $TAR -C "${2}" >/dev/null
    popd
}

function install_github_releases_app {
	TARURL=`get_download_url $1 | grep tar | head -n 1`
    URL=${TARURL:-`get_download_url $1 | head -n 1`}
    FILE=$(basename $URL)
    echo "URL: ${URL}"
    echo "FILE: ${FILE}"

    if [[ "$FILE" == *".tar.gz" ]]; then
        echo "Source download is a tar.gz"
        install_targz "${URL}" "${2}" "${3}"
    else
        echo "Source download is a binary (we think)"
        install_binary "${URL}" "${2}" "${3}"
    fi
}

app=${1?"Usage: $0 author/app"}
dest=${2:-"${HOME}/.local/bin"}
appname=${3:-"${app##*/}"}

echo "app=${app}"
echo "dest=${dest}"
echo "appname=${appname}"

install_github_releases_app $app $dest $appname
