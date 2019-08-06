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

terraform_prompt_info() {
    # check if in terraform dir
    if [ -d .terraform ]; then
        workspace=$(terraform workspace show 2> /dev/null) || return
        echo "[${workspace}]"
    fi
}

function_exists() {
    FUNCTION_NAME=$1
    [ -z "$FUNCTION_NAME" ] && return 1
    declare -F "$FUNCTION_NAME" > /dev/null 2>&1
    return $?
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
    pathlist=`echo "${PATH}" | sed 's/:/\n/g' | uniq`
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

join () {local IFS="$1"; shift; echo "$*"}

load_ssh_agent () {
    local SSH_ENV=${1:-"${HOME}/.ssh/environment"}
    if type ssh-agent &>/dev/null; then
        echo "Initializing new SSH agent..."
        touch "${SSH_ENV}"
        chmod 600 "${SSH_ENV}"
        /usr/bin/ssh-agent | sed 's/^echo/#echo/' >> "${SSH_ENV}"
        . "${SSH_ENV}" > /dev/null
        /usr/bin/ssh-add
    fi
}

start_ssh_agent () {
    local SSH_ENV=${1:-"${HOME}/.ssh/environment"}
    if [ -f "${SSH_ENV}" ]; then
        . "${SSH_ENV}" > /dev/null
        kill -0 $SSH_AGENT_PID 2>/dev/null || {
            load_ssh_agent
        }
    else
        load_ssh_agent
    fi
}
