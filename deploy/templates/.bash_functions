#!/bin/bash
add-to-path() {
    newelement=${1%/}
    if [ -d "$1" ] && ! echo $PATH | grep -E -q "(^|:)$newelement($|:)" ; then
        if [ "$2" = "after" ] ; then
            PATH="$PATH:$newelement"
        else
            PATH="$newelement:$PATH"
        fi
    fi
}

rm-from-path() {
    PATH="$(echo $PATH | sed -e "s;\(^\|:\)${1%/}\(:\|\$\);\1\2;g" -e 's;^:\|:$;;g' -e 's;::;:;g')"
}

# Functions to help us manage paths.
remove-from-path () {
    # Second argument is the name of the
    # path variable to be modified (default: PATH)
    local IFS=':'
    local NEWPATH
    local DIR
    local pathvar=${2:-PATH}
    for DIR in ${!pathvar} ; do
        if [ "$DIR" != "$1" ] ; then
            NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
        fi
    done
    export $pathvar="$NEWPATH"
}

prepend-to-path () {
    remove-from-path $1 $2
    local pathvar=${2:-PATH}
    export $pathvar="$1${!pathvar:+:${!pathvar}}"
}

append-to-path () {
    remove-from-path $1 $2
    local pathvar=${2:-PATH}
    export $pathvar="${!pathvar:+${!pathvar}:}$1"
}

remove-dups-from-path () {
    local PATHVARIABLE=${2:-PATH}
    pathlist=`echo "${PATH}"" | sed 's/:/\n/g' | uniq`
    echo "PATH (Original): $PATH"
    unset PATH
    # echo "After unset, PATH: $PATH"
    for dir in $pathlist; do
        if test -d "${dir}" ; then
            if test -z "${PATH}"; then
                PATH="${dir}"
            else
                PATH="${PATH}:${dir}"
            fi
        else
            echo "Invalid Path Removed: ${dir}"
        fi
    done
    echo "PATH (Updated): $PATH"
    export PATH
}

join-array () {
    IFS="$1"
    shift
    echo "$*"
}

load-ssh-agent () {
    SSH_ENV=${1:-"${HOME}/.ssh/environment"}
    if type ssh-agent &>/dev/null; then
        echo "Initializing new SSH agent..."
        touch "${SSH_ENV}"
        chmod 600 "${SSH_ENV}"
        /usr/bin/ssh-agent | sed 's/^echo/#echo/' >> "${SSH_ENV}"
        . "${SSH_ENV}" > /dev/null
        /usr/bin/ssh-add
    fi
}

start-ssh-agent () {
    SSH_ENV=${1:-"${HOME}/.ssh/environment"}
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        kill -0 $SSH_AGENT_PID 2>/dev/null || {
            load-ssh-agent
        }
    else
        load-ssh-agent
    fi
}

#init-kubeconfig () {
#    if [[ `ls ~/.kube/config | grep kubeconfig | wc -l` != 0 ]]; then
#        for f in `ls ~/.kube/config/ | grep kubeconfig`; do
#            export KUBECONFIG="$HOME/.kube/config/$f:$KUBECONFIG"; done && \
#            export KUBECONFIG=$(echo $KUBECONFIG | sed 's/:$//') && \
#    fi
#    kubectl config get-contexts
#}
#export -f init-kubeconfig

export -f add-to-path
export -f rm-from-path
export -f remove-from-path
export -f prepend-to-path
export -f append-to-path
export -f remove-dups-from-path
export -f join-array
export -f start-ssh-agent
export -f load-ssh-agent
