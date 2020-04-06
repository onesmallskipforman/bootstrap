#!/bin/zsh

DIR=$(dirname $0)

function bootstrap() {
  mkdir -p "$1"
  git -C "$1" init
  git -C "$1" remote add origin "$2"
  git -C "$1" pull origin master
  # # git -C "$1" clean -fdX
}

function doIt() {

  echo $DIR

  # boostrap scripts
  bootstrap $DIR "https://github.com/onesmallskipforman/bootstrap.git"

  # public dotfiles
  PUBLIC="$DIR/Filesystem"
  bootstrap "$PUBLIC" "https://github.com/onesmallskipforman/dotfiles.git"

  # private dotfiles
  PRIVATE="$PUBLIC/.local/share"
  bootstrap "$PRIVATE" "https://github.com/onesmallskipforman/userdata.git"

  # remove old files, then symlink (or copy)
  rm -rf "$HOME"/{.config,.local,.zshenv}
  ln -sf "$DIR/Filesystem"/{.config,.local,.zshenv} "$HOME"
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
