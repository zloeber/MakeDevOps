# .bash_profile

# Get the main bash profile loaded
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# Ensure our binpath is always on the path
export PATH="${HOME}/.local/bin:${PATH}"

# Source in custom functions
if [ -f $HOME/.bash_functions ]; then
    . $HOME/.bash_functions
fi

# Bash exports
if [ -f ~/.bash_exports ]; then
    . ~/.bash_exports
fi

# Source in custom bash cli completions
if [ -f $HOME/.bash_completions ]; then
    . $HOME/.bash_completions
fi

# Bash prompt
if [ -f ~/.bash_prompt ]; then
    . ~/.bash_prompt
fi

# ssh agent loading
#start-ssh-agent && echo "ssh-agent: Loaded"