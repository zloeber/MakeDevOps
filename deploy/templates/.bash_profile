# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Ensure our binpath is always on the path
export PATH="${HOME}/.local/bin:${PATH}"

# Source in custom functions
if [ -f $HOME/.bash_functions ]; then
    . $HOME/.bash_functions
fi

# Source in custom bash cli completions
if [ -f $HOME/.bash_completions ]; then
    . $HOME/.bash_completions
fi

# Bash exports 
if [ -f ~/.bash_exports ]; then
    . ~/.bash_exports
fi

