#!/usr/bin/env bash
# Time-stamp: <2016-11-28 16:31:04 kmodi>
# https://discuss.gohugo.io/t/auto-generate-file-name-based-on-title/4648/2?u=kaushalmodi

h="
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                 │
│ Script        : hugo_new_post.sh                                                │
│ Description   : Script to generate a hugo post file using the title specified   │
│                 at the command line.                                            │
│ Usage Example : hugo_new_post.sh -b \"/home/$USER/hugo/myblog\" -t \"My New Post\"  │
│                                                                                 │
│                                                                                 │
│ OPTIONS                                                                         │
│                                                                                 │
│   -b|--blogpath <path> : Root of hugo blog. (Mandatory argument)                │
│                           --blogpath \"/home/\$USER/hugo/myblog\"                  │
│                                                                                 │
│   -t|--title <string>  : Title string of the post. (Mandatory argument)         │
|                          Use double quotes if the title contains spaces.        │
│                           --title \"My New Post\"                                 │
│                                                                                 │
│   -s|--section <dir>    : Sub-directory in the 'content/' dir where the post    │
│                          should be created. (Default: posts)                    │
│                           --section \"blog\"                                      │
│                                                                                 │
│                                                                                 │
│   -h|--help            : Show this help                                         │
│   -d|--debug           : Debug mode                                             │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘"

blog_path=""
section="posts"
title=""
extra_args=""
here=$(pwd)
fext=".md"

debug=0
help=0

while [ $# -gt 0 ]
do
    case "$1" in
        "-b"|"--blogpath" ) shift
                            blog_path="$1";;
        "-t"|"--title" ) shift
                         title="$1";;
        "-s"|"--section" ) shift
                           section="$1";;
        "-d"|"--debug" ) debug=1;;
        "-h"|"--help" ) help=1;;
        * ) extra_args="${extra_args} $1";;
    esac
    shift # expose next argument
done

if [[ ${debug} -eq 1 ]]
then
    echo "blog path  = ${blog_path}"
    echo "title      = ${title}"
    echo "sub dir    = ${section}"
    echo "extra args = ${extra_args}"
fi

main () {
    # Remove leading and trailing whitespace from ${title}
    title=$(echo "${title}" | \sed -r -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    # Using ${title}
    #  - Replace '&' with "and", and '.' with "dot".
    #  - Then lower-case the whole title.
    #  - Then replace all characters except a-z, 0-9 and '-' with spaces.
    #  - Then remove leading/trailing spaces if any.
    #  - Then replace one or more spaces with a single hyphen.
    # For example, converts "This, That \& Other!" to "this-that-and-other.md"
    # (Note that we need to escape & with \ above, in the shell.)
    fname=$(echo "${title}" \
                | sed -r -e 's/&/ and /g' \
                    -e 's/\./ dot /g' \
                    -e 's/./\L\0/g' \
                    -e 's/[^a-z0-9-]/ /g' \
                    -e 's/^[[:space:]]*//g' \
                    -e 's/[[:space:]]*$//g' \
                    -e 's/[[:space:]]+/-/g');
    fpath="${blog_path}/${section}/${fname}${fext}"

    if [[ ${debug} -eq 1 ]]
    then
        echo "fname      = ${fname}"
        echo "fpath      = ${fpath}"
    fi

    # Create the new post

    hugo new "${fpath}" ${extra_args}

    # Replace the title in TOML front matter with ${title}, and add slug
    tmp_file="/tmp/${USER}_hugo_post"
    cp -f ${fpath} ${tmp_file}
    sed -r -e 's/^(\s*title = ).*/\1"'"${title}"'"/' \
         -e 's/^(\s*title = .*)/\1\nslug = "'"${fname}"'"/' \
        ${tmp_file} > ${fpath}
    rm -f ${tmp_file}

    # Open the file in EDITOR with cursor placed on the last line
    last_line=$(wc -l ${fpath} | awk '{ print $1 }')
    open_file_cmd="${EDITOR} +${last_line} ${fpath} &"
    if [[ ${debug} -eq 1 ]]
    then
        echo "last line     = ${last_line}"
        echo "open file cmd = ${open_file_cmd}"
    fi
    #eval "${open_file_cmd}"
}

help () {
    echo "${h}"
}

if [[ ${help} -eq 1 ]]
then
    help
    exit 0
elif [[ -z ${blog_path} || -z ${title} ]]
then
    echo "Error: Both '-b' and '-t' are mandatory arguments"
    help
    exit 1
else
    main
    exit 0
fi