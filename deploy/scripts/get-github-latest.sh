#!/bin/bash
# get-github-latest.sh <url> <platform> <destination>
#
# get-github-latest.sh 'https://github.com/jenkins-x/jx/releases/latest' 'linux-amd64' 'jx.tar.gz'

function get_download_url {
	wget -q -nv -O- https://api.github.com/repos/$1/releases/latest 2>/dev/null |  jq -r '.assets[] | select(.browser_download_url | contains("linux-amd64")) | .browser_download_url'
}

function install_binary {
    pushd /tmp
    TAR="${3}.tar.gz"
	URL=$(get_download_url $1 | head -n 1)
    echo "URL: ${URL}"
	BASE=$(basename $URL)
	wget -q -nv -O $BASE $URL 
	if [ ! -f $BASE ]; then
		echo "Didn't download $URL properly.  Where is $BASE?"
		exit 1
	fi
	mv $BASE "${TAR}"
    rm -rf ./$3
    mkdir -p $2
    tar -xzvf "${TAR}"
    rm -rf "${2}/${3}"
    mv ./$3 $2
    popd
}

install_binary jenkins-x/jx "${HOME}/.local/bin" jx