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

# Load zsh-syntax-highlighting; should be last.
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
