#!/bin/bash

function get_download_url {
	wget -q -nv -O- https://api.github.com/repos/$1/releases/latest 2>/dev/null |  jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url'
}

function install_binary {
    pushd /tmp
    TAR="${3}.tar.gz"
	URL=$(get_download_url $1 | head -n 1)
    FILE=$(basename $URL)
    echo "URL: ${URL}"
    echo "FILE: ${FILE}"
    rm -rf $TAR
	wget -q -nv -O $TAR $URL
	if [ ! -f $TAR ]; then
		echo "Cannot download $FILE from $URL"
        popd
		exit 1
	fi

    # Extract to target directory
    mkdir -p $2
    rm -f "${2}/${3}"
    tar -xzvf $TAR -C $2
    popd
}

install_binary jenkins-x/jx "${HOME}/.local/bin" jx