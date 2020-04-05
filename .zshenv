# Skipper's .zshenv

# Path Variables
export PATH="$PATH:$HOME/.local/bin/"
export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/Library/TeX/texbin"
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

# set xdg env variables
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

# ~/ Clean-up:
export BUNDLE_USER_CONFIG="$XDG_CONFIG_HOME"/bundle      # ruby bundler
export BUNDLE_USER_CACHE="$XDG_CACHE_HOME"/bundle
export BUNDLE_USER_PLUGIN="$XDG_DATA_HOME"/bundle
export CARGO_HOME="$XDG_DATA_HOME"/cargo                 # Rust Cargo
export DOCKER_CONFIG="$XDG_CONFIG_HOME"/docker           # docker
export GEM_HOME="$XDG_DATA_HOME"/gem                     # ruby gems
export GEM_SPEC_CACHE="$XDG_CACHE_HOME"/gem
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"                # gnupg
export IPYTHONDIR="$XDG_CONFIG_HOME"/jupyter             # ipython
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME"/jupyter     # jupyter
export LESSHISTFILE="-"                                  # less history
export PASSWORD_STORE_DIR="$XDG_DATA_HOME"/pass          # pass
export PLATFORMIO_CORE_DIR="$XDG_CONFIG_HOME/platformio" # platformio
export PYLINTHOME="$XDG_CACHE_HOME/pylint"               # pylint
export VIMINIT="source $XDG_CONFIG_HOME/vim/vimrc"       # vim
export ZDOTDIR="$HOME/.config/zsh"                       # zsh

# other
export EDITOR="/usr/local/bin/vim"
export BACKUP="$HOME/Dropbox/Backup"
