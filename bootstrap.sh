#!/bin/sh

# to go project dir and update
cd $(dirname $0);
git pull origin master;

function doIt() {
  rsync --exclude ".git/" \
        --exclude ".DS_Store" \
        --exclude "bootstrap.sh" \
        --exclude "Experimental/" \
        --exclude "README.md" \
        -avh --no-perms . ~/.dotfiles;
  source ~/.zshrc;
}

if [ "$1" == "--force" -o "$1" == "-f" ]; then
  doIt;
else
  read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
  echo "";
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
  fi;
fi;
unset doIt;
