#!/bin/bash
set -eu

main() {
    local args=("$@")
    local inFile=$(pwd)/docker-compose.yml
    local outFile=$(pwd)/$1

    if [[ $# -lt 2 ]]; then
        usage
    fi

    cp $inFile $outFile
    for ((i=1; i<${#args[@]}; i++)); do
        local pair=(${args[i]//=/ }) # tokenize by =
        pair[1]="${pair[1]//\//\\/}" # escape paths
        sed -i -e "s/\${${pair[0]}}/${pair[1]}/g" $outFile
        echo "Replacing: $i  \${${pair[0]}} with ${pair[1]}"
    done
}

usage(){
	echo "replace-var 1.0"
	echo "Substitutes variables of type \${VAR1} in docker-compose.yml and writes them into the file defined as the first argument"
	echo "Usage: replace-var result.yml VAR1=value1 VAR2=value2 ..."
}

main $@