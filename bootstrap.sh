#!/bin/zsh

function bootstrap() {
  mkdir -p "$1"
  git -C "$1" init
  git -C "$1" remote add origin "$2"
  git -C "$1" pull origin master
  # # git -C "$1" clean -fdX
}

function doIt() {

  # boostrap scripts
  boostrap $PWD "https://github.com/onesmallskipforman/bootstrap.git"

  # public dotfiles
  PUBLIC="$PWD/Filesystem"
  boostrap "$PUBLIC" "https://github.com/onesmallskipforman/dotfiles.git"

  # private dotfiles
  PRIVATE="$PUBLIC/.local/share"
  boostrap "$PRIVATE" "https://github.com/onesmallskipforman/userdata.git"

  # remove old files, then symlink (or copy)
  rm -rf "$HOME"/{.config,.local,.zshenv}
  ln -sf "$PWD/Filesystem"/* "$HOME"
  # cp -r "$PWD/.config"/* "$HOME"

}

if [[ "$1" == "--force" ]] || [[ "$1" == "-f" ]]; then
  doIt;
else
  printf '%s ' "This may overwrite existing files in your home directory. Are you sure? (y/n)";
  read REPLY;

  if [[ $REPLY =~ ^[Yy]$ ]]; then
    doIt;
  fi;
fi;
unset doIt;
