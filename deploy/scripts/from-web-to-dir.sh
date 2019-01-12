#!/usr/bin/env bash

# Useful for simple binary download install to some other path
# $1 = uri
# $2 = path
# $3 = filename
#
# example: > ./from-web-to-dir.sh 'https://raw.githubusercontent.com/geerlingguy/awx-container/master/docker-compose.yml' '/tmp/awx-server' 'docker-compose.yml'

help() {
	echo "Usage: ./from-web-to-dir.sh"
    echo ""
	echo "Useful for simple binary download install to some other path"
	echo ""
    echo "./from-web-to-dir.sh \\"
    echo "'https://raw.githubusercontent.com/geerlingguy/awx-container/master/docker-compose.yml' '/tmp/awx-server' 'docker-compose.yml'"
}

# Run the command if we're not being sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
	if [ -z "$1" ]; then 
		help
		exit
	fi

    uri="$1"

    if [ "${3}" == '*' ]; then 
		echo "Seriously? Not smart..."
		exit
	fi

    if [ -z "$2" ]; then
        outpath="."
    else
	    outpath="$2"
	fi

    if [ -z "$3" ]; then
        outfile=$(basename "${uri}")
    else
        outfile="$3"
	fi

    fulloutpath="${outpath}/${outfile}"

    echo "URI: ${uri}"
    echo "Download To: ${fulloutpath}"
    rm -rf "${outpath}/${outfile}"
    mkdir -p "${outpath}"
    curl -o "${fulloutpath}" -fsSL ${uri}
    echo "Complete!"
fi
