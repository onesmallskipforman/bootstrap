#!/bin/zsh

# git pull origin master;

# git clean -dfX

function doIt() {

  # # download files from github
  # REPO="https://github.com/onesmallskipforman/Backup.git"
  # BACKUP="$XDG_DATA_HOME"
  # mkdir -p "$BACKUP"

  # git -C "$BACKUP" init
  # git -C "$BACKUP" remote add origin "$REPO"
  # git -C "$BACKUP" pull origin master
  # git -C "$BACKUP" clean -fdX

  # remove old files
  rm -rf "$HOME/.config"
  rm -rf "$HOME/.local"
  rm -rf "$HOME/.zshenv"

  # symlink (or copy) .config, .local and .zshrc
  ln -sf "$PWD/Filesystem/.config" "$HOME"
  ln -sf "$PWD/Filesystem/.local"  "$HOME"
  ln -sf "$PWD/Filesystem/.zshenv" "$HOME"

  # cp -r "$PWD/.config" "$HOME"
  # cp -r "$PWD/.local"  "$HOME"
  # cp -r "$PWD/.zshrc"  "$HOME"

  # move application support

  # rm -rf ~/.dotfiles
  # rsync -a --delete --delete-excluded --info=progress2 \
  #   --exclude ".git/" \
  #   --exclude ".gitignore" \
  #   --exclude ".DS_Store" \
  #   --exclude "Experimental/" \
  #   --exclude "README.md" \
  #   --exclude "todo.txt" \
  #   --exclude ".zshrc" \
  #   . ~/.dotfiles/;

  # rsync -a --delete --info=progress2 \
  #   --no-perms .zshrc ~/.zshrc;
}

if [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]]; then
  doIt;
else
  # read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  # echo "";
  printf '%s ' "This may overwrite existing files in your home directory. Are you sure? (y/n)";
  read REPLY;

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
  fi;
fi;
unset doIt;
