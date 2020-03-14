# Dependancies You Need for this Config
# zsh-syntax-highlighting - syntax highlighting for ZSH in standard repos
# autojump - jump to directories with j or jc for child or jo to open in file manager
# zsh-autosuggestions - Suggestions based on your history

export PATH="$PATH:/usr/local/sbin"
export PATH="$PATH:/Library/TeX/texbin"
# export EDITOR="/usr/local/bin/vim"

export BACKUP="$HOME/Dropbox/Backup"

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
HISTFILE=~/.cache/zsh/history

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)# Include hidden files.

# Load zsh-syntax-highlighting, zsh-autosuggestions; should be last.
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/local/share/autojump/autojump.zsh
