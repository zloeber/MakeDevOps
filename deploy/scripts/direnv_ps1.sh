
# Used for Python virtual environments
show_virtual_env() {
    if [ -n "$VIRTUAL_ENV" ]; then
        echo "($(basename $VIRTUAL_ENV))"
    fi
}
export -f show_virtual_env
#PS1='$(show_virtual_env)'$PS1
