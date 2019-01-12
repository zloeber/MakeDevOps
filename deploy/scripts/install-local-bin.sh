#!/bin/bash
# Example
#   install-github-release.sh https://azuredraft.blob.core.windows.net/draft/draft-v0.16.0-linux-amd64.tar.gz draft "${HOME}/.local/bin" "linux-amd64"
#
# Author: Zachary Loeber

function get_download_url {
	wget -q -nv -O- https://api.github.com/repos/$1/releases/latest 2>/dev/null |  jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url'
}

function install_binary {
    # 1 = source download link
    # 2 = destination folder
    # 3 = destination binary name
    src="${1}"
    app="${2}"
    dst="${3}"
    srcpath="${4}"

    echo "Download and install ${app} binary to ${2}"
    rm -rf "${2}/${3}"
    mkdir -p "${2}"
    curl -o "${2}/${3}" -fsSL ${1}
    chmod +x "${2}/${3}"
}

function install_targz {
    # 1 = source download link
    # 2 = app name
    # 3 = destination folder
    # 4 = source folder path (post extraction)
    src="${1}"
    app="${2}"
    dst="${3}"
    srcpath="${4}"
    echo "Download, extract, and install ${app} binary to ${dst}"

    TAR="${app}.tar.gz"
    rm -rf "/tmp/${TAR}"

    wget -q -nv -O "/tmp/${TAR}" $src
	if [ ! -f "/tmp/${TAR}" ]; then
		echo "Cannot download $src"
		exit 1
	fi

    # Extract to target directory
    mkdir -p "${dst}"
    rm -rf "${dst}/${app}"
    tar -xzvf "/tmp/${TAR}" -C "/tmp"
    cp "/tmp/${srcpath}${app}" $dst
}

function install_app {
    src="${1}"
    app="${2}"
    dst="${3}"
    srcpath="${4}"
    download=$(basename $src)

    echo "src: ${src}"
    echo "app: ${app}"
    echo "download: ${download}"
    echo "dst: ${dst}"
    echo "srcpath: ${srcpath}"

    if [[ "$download" == *".tar.gz" ]]; then
        echo "Source download is a tar.gz"
        install_targz $src $app $dst $srcpath
    else
        echo "Source download is a binary (we think)"
        install_binary $src $app $dst
    fi
}

src=${1?"Usage: $0 https://someurl.com/package.tar.gz package"}
app=${2?"Usage: $0 https://someurl.com/package.tar.gz package"}
dst=${3:-"${HOME}/.local/bin"}
srcpath=${4:-""}

echo "src=${src}"
echo "app=${app}"
echo "dst=${dst}"
echo "srcpath=${srcpath}"

install_app $src $app $dst $srcpath
