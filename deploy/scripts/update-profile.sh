#!/bin/env bash
set -xeu

if [ $# -eq 0 ]; then
    exit 0
fi

if [ $# -eq 1 ]; then
    LINE=${1}
    SHELL_TARGET="bash"
fi

# Check if we passed in a shell or not. Default to bash
if [[ -z "${SHELL_TARGET}" ]]; then
    SHELL_TARGET=${1}
    LINE=${2}
fi

if [ $SHELL_TARGET -eq "bash" ]; then
    PROFILEPATH="${HOME}/.bashrc"
fi

if [ $SHELL_TARGET -eq "zsh" ]; then
    PROFILEPATH="${HOME}/.zshrc"
fi

if [[ -z "${PROFILEPATH}" ]]; then
    echo "Invalid shell ${SHELL_TARGET}!"
    exit 1
fi

echo "Profile Path: ${PROFILEPATH}"

cat $PROFILEPATH | grep "\$${LINE}^"

main() {
    local args=("$@")

    if [[ $# -lt 2 ]]; then
        usage
    fi

##### WIP!!

    for ((i=1; i<${#args[@]}; i++)); do
        local pair=(${args[i]//=/ }) # tokenize by =
        pair[1]="${pair[1]//\//\\/}" # escape paths
        sed -i -e "s/\${${pair[0]}}/${pair[1]}/g" $outFile
        echo "Replacing: $i  \${${pair[0]}} with ${pair[1]}"
    done
}

usage(){
	echo "update-profile.sh"
	echo "Updates a bash or zsh profile with provided line only if it does not already exist."
	echo "Usage: update-profile.sh 'export PATH=\$HOME\.local\bin:\$PATH'"
}

main $@