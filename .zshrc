# Dependancies You Need for this Config
# zsh-syntax-highlighting - syntax highlighting for ZSH in standard repos
# autojump - jump to directories with j or jc for child or jo to open in file manager
# zsh-autosuggestions - Suggestions based on your history

# aliases
# TODO: make alias file
# [ -f "$HOME/.config/aliasrc" ] && source "$HOME/.config/aliasrc"
alias icat="kitty +kitten icat"

# export PATH="$PATH:$(du "$HOME/.local/bin/" | cut -f2 | tr '\n' ':' | sed 's/:*$//')"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.cache"

# Adds `~/.local/bin` to $PATH
export PATH="$PATH:$HOME/.local/bin/"

export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/Library/TeX/texbin"
# export EDITOR="/usr/local/bin/vim"

export BACKUP="$HOME/Dropbox/Backup"

# move vim and gnupg config files
export VIMINIT="source $XDG_CONFIG_HOME/vim/vimrc"
export GNUPGHOME="$XDG_CONFIG_HOME/gnupg"

LESSHISTFILE="$XDG_DATA_HOME/less/lesshst"


# prompt management
# eval "$(starship init zsh)"
autoload -U colors && colors
# export PS1="[ %n %1~ ] ❯ "
# export PS1="%B%{$fg[red]%}$PS1 %{$reset_color%}"
export PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%1~%{$fg[red]%}]%{$reset_color%}$%b "

if [[ $1 == eval ]]
then
    "$@"
set --
fi

# History in cache directory:
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$XDG_DATA_HOME/zsh/zsh_history"

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit -d "$XDG_DATA_HOME/zsh/zcompdump"
_comp_options+=(globdots)# Include hidden files.

# vi mode
bindkey -v
export KEYTIMEOUT=1

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Use lf to switch directories and bind it to ctrl-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

# turn CTRL+z into a toggle switch (buggy atm)
# ctrlz() {
#   if [[ $#BUFFER == 0 ]]; then
#     fg >/dev/null 2>&1 && zle redisplay
#   else
#     zle push-input
#   fi
# }
# zle -N ctrlz
# bindkey '^z' ctrlz

# Load zsh-syntax-highlighting, zsh-autosuggestions; should be last.
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/autojump/autojump.zsh
