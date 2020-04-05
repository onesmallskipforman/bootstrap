#!/bin/zsh

# TODO: find way to login to github without osxkeychain

# # to go project dir and update
cd "$(dirname $0)";
# git pull origin master;

function doIt() {

  # download dotfiles from github

  # remove old files
  rm -rf "$HOME/.config"
  rm -rf "$HOME/.local"

  # symlink (or copy) .config, .local and .zshrc
  ln -sf "$PWD/.config" "$HOME"
  ln -sf "$PWD/.local"  "$HOME"
  ln -sf "$PWD/.zshrc"  "$HOME"

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
