#!/bin/zsh
#
# Only including a shebang to trigger Sublime Text to use shell
# syntax highlighting.
#
# Copyright 2006-2018 Joseph Block <jpb@unixorn.net>
#
# BSD licensed, see LICENSE.txt

# Clone zgen if you haven't already
if [[ -z "$ZGEN_PARENT_DIR" ]]; then
  ZGEN_PARENT_DIR="${HOME}/.zgen"
  echo "ZGEN_PARENT_DIR: ${ZGEN_PARENT_DIR}"
fi
if [[ ! -f $ZGEN_PARENT_DIR/zgen.zsh ]]; then
  git clone https://github.com/tarjoilija/zgen.git $ZGEN_PARENT_DIR
fi

# Source zgen for the rest of this deployment
source $ZGEN_PARENT_DIR/zgen.zsh
unset ZGEN_PARENT_DIR

load-starter-plugin-list() {
  echo "Creating a zgen save"
  ZGEN_LOADED=()
  ZGEN_COMPLETIONS=()

  zgen oh-my-zsh

  # If you want to customize your plugin list, create a file named
  # .zgen-local-plugins in your home directory. That file will be sourced
  # during startup *instead* of running this load-starter-plugin-list function,
  # so make sure to include everything from this function that you want to keep.

  # If zsh-syntax-highlighting is bundled after zsh-history-substring-search,
  # they break, so get the order right.
  zgen load zsh-users/zsh-syntax-highlighting
  zgen load zsh-users/zsh-history-substring-search

  # Set keystrokes for substring searching
  zmodload zsh/terminfo
  bindkey "$terminfo[kcuu1]" history-substring-search-up
  bindkey "$terminfo[kcud1]" history-substring-search-down

  # Tab complete rakefile targets.
  zgen load unixorn/rake-completion.zshplugin

  # Automatically run zgen update and zgen selfupdate every 7 days.
  zgen load unixorn/autoupdate-zgen

  # Add my collection of miscellaneous utility functions.
  zgen load unixorn/jpb.zshplugin

  # Colorize the things if you have grc installed. Well, some of the
  # things, anyway.
  zgen load unixorn/warhol.plugin.zsh

  # macOS helpers. This plugin is smart enough to detect when it isn't running
  # on macOS and not load itself, so you can safely share the same plugin list
  # across macOS and Linux/BSD.
  zgen load unixorn/tumult.plugin.zsh

  # Warn you when you run a command that you've set an alias for without
  # using the alias.
  zgen load djui/alias-tips

  # Add my collection of git helper scripts.
  zgen load unixorn/git-extra-commands

  # Add my bitbucket git helpers plugin.
  zgen load unixorn/bitbucket-git-helpers.plugin.zsh

  # A collection of scripts that might be useful to sysadmins.
  zgen load skx/sysadmin-util

  # Adds aliases to open your current repo & branch on github.
  zgen load peterhurford/git-it-on.zsh

  # Tom Limoncelli's tooling for storing private information (keys, etc)
  # in a repository securely by encrypting them with gnupg.
  zgen load StackExchange/blackbox

  # Load some oh-my-zsh plugins
  zgen oh-my-zsh plugins/pip
  zgen oh-my-zsh plugins/sudo
  zgen oh-my-zsh plugins/aws
  zgen oh-my-zsh plugins/chruby
  zgen oh-my-zsh plugins/colored-man-pages
  zgen oh-my-zsh plugins/git
  zgen oh-my-zsh plugins/github
  zgen oh-my-zsh plugins/python
  zgen oh-my-zsh plugins/rsync
  zgen oh-my-zsh plugins/screen
  zgen oh-my-zsh plugins/vagrant

  if [ $(uname -a | grep -ci Darwin) = 1 ]; then
    # Load macOS-specific plugins
    zgen oh-my-zsh plugins/brew
    zgen oh-my-zsh plugins/osx
  fi

  # A set of shell functions to make it easy to install small apps and
  # utilities distributed with pip.
  zgen load sharat87/pip-app

  zgen load chrissicool/zsh-256color

  # Load more completion files for zsh from the zsh-lovers github repo.
  zgen load zsh-users/zsh-completions src

  # Docker completion
  zgen load srijanshetty/docker-zsh

  # Load me last
  GENCOMPL_FPATH=$HOME/.zsh/complete

  # Very cool plugin that generates zsh completion functions for commands
  # if they have getopt-style help text. It doesn't generate them on the fly,
  # you'll have to explicitly generate a completion, but it's still quite cool.
  zgen load RobSis/zsh-completion-generator

  # Add Fish-like autosuggestions to your ZSH.
  zgen load zsh-users/zsh-autosuggestions

  # k is a zsh script / plugin to make directory listings more readable,
  # adding a bit of color and some git status information on files and
  # directories.
  zgen load supercrabtree/k

  # Bullet train prompt setup.
  zgen load caiogondim/bullet-train-oh-my-zsh-theme bullet-train

  # Save it all to init script.
  zgen save
}

setup-zgen-repos() {
  if [[ -f ~/.zgen-local-plugins ]]; then
    source ~/.zgen-local-plugins
  else
    load-starter-plugin-list
  fi
}

setup-custom-exports() {
  if [[ -f ~/.zsh_exports ]]; then
    source ~/.zsh_exports
  fi
}


setup-custom-functions() {
  if [[ -f ~/.zsh_functions ]]; then
    source ~/.zsh_functions
  fi
}

setup-custom-completions() {
  if [[ -f ~/.zsh_completions ]]; then
    source ~/.zsh_completions
  fi
}

# This comes from https://stackoverflow.com/questions/17878684/best-way-to-get-file-modified-time-in-seconds
# This works on both Linux with GNU fileutils and macOS with BSD stat.

# Naturally BSD/macOS and Linux can't share the same options to stat.
if [[ $(uname | grep -ci -e Darwin -e BSD) = 1 ]]; then

  # macOS version.
  get_file_modification_time() {
    modified_time=$(stat -f %m "$1" 2> /dev/null) || modified_time=0
    echo "${modified_time}"
  }

elif [[ $(uname | grep -ci Linux) = 1 ]]; then

  # Linux version.
  get_file_modification_time() {
    modified_time=$(stat -c %Y "$1" 2> /dev/null) || modified_time=0
    echo "${modified_time}"
  }
fi

# check if there's an init.zsh file for zgen and generate one if not.
if ! zgen saved; then
  setup-zgen-repos
fi

# Our installation instructions get the user to make a symlink
# from ~/.zgen-setup to wherever they checked out the zsh-quickstart-kit
# repository.
#
# Unfortunately, stat will return the modification time of the
# symlink instead of the target file, so construct a full path to hand off
# to stat so it returns the modification time of the actual .zgen-setup file.
if [[ -f ~/.zgen-setup ]]; then
  REAL_ZGEN_SETUP=~/.zgen-setup
fi
if [[ -L ~/.zgen-setup ]]; then
  REAL_ZGEN_SETUP="$(readlink ~/.zgen-setup)"
fi

# If you don't want my standard starter set of plugins, create a file named
# .zgen-local-plugins and add your zgen load commands there. Don't forget to
# run `zgen save` at the end of your .zgen-local-plugins file.
#
# Warning: .zgen-local-plugins REPLACES the starter list setup, it doesn't
# add to it.
#
# Use readlink in case the user is symlinking from another repo checkout, so
# they can use a personal dotfiles repository cleanly.
if [[ -f ~/.zgen-local-plugins ]]; then
  REAL_ZGEN_SETUP=~/.zgen-local-plugins
fi
if [[ -L ~/.zgen-local-plugins ]]; then
  REAL_ZGEN_SETUP="${HOME}/$(readlink ~/.zgen-local-plugins)"
fi

# If .zgen-setup is newer than init.zsh, regenerate init.zsh
if [ $(get_file_modification_time ${REAL_ZGEN_SETUP}) -gt $(get_file_modification_time ~/.zgen/init.zsh) ]; then
  echo "$(basename ${REAL_ZGEN_SETUP}) updated; creating a new init.zsh"
  setup-zgen-repos
fi
unset REAL_ZGEN_SETUP

# Setup exports file if exists
setup-custom-functions
setup-custom-exports
setup-custom-completions
