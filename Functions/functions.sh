# shell functions for configuring and installing various programs

#===============================================================================
# SYSTEM PREP
#===============================================================================

function dotfiles() {

  function gitstrap() {
    git -C "$2" init
    git -C "$2" remote add origin "$1"
    git -C "$2" fetch --depth 1 origin master
    git -C "$2" reset --hard origin/master
  }

  # bootstrap scripts and configs
  bigprint "Syncing dotfiles repo to home"
  GHUB="https://github.com/onesmallskipforman"
  clonepull "$GHUB/bootstrap.git" "$1"

  # dotfile boostrap
  mkdir -p "Home"
  mv -n "$HOME"/{.config,.local,.zshenv} "$1/Home" &>/dev/null
  gitstrap "$GHUB/dotfiles.git"  "$1/Home"
  gitstrap "$GHUB/userdata.git"  "$1/Home/.local/share"

  # symlink
  ln -sf "$1/Home"/{.config,.local,.zshenv} "$HOME"
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function pip_install() {
  bigprint "Installing Pip Packages"
  pip3 install -r "$HOME/.config/packages/requirements.txt"
  echo "Pip Installation Complete."
}

function cargo_install() {
  bigprint "Installing Cargo Packages"
  which rustup &>/dev/null || (
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    rustup override set stable
  )
  rustup update stable
  source $HOME/.cargo/env
  cat "$HOME/.config/cargo/cargo_$OS.txt" | xargs -n1 cargo install --git
  # after cloning https://github.com/alacritty/alacritty.git
  # cd $HOME/.local/src/alacritty
  # option 1
  # cargo install cargo-deb
  # cargo deb --install -p alacritty
  # option 2 (something is not working here)
  # cargo build --release
  # option 3
  # cargo install --git https://github.com/alacritty/alacritty
  # option 4
  # make binary
}

function git_install() {
  bigprint "Cloning Git Repos"
  while IFS= read URL; do
    DIR=$HOME/.local/src/$(basename "$URL" .git)
    clonepull "$URL" "$DIR"
  done < "$HOME/.config/packages/repos_$OS.txt"
  echo "Repo Cloning Complete."
}

#===============================================================================
# UTILITIES
#===============================================================================

function bigprint() {
  # print section
  echo ""
  echo "-------------------------------------------------------------------"
  echo "$1"
  echo "-------------------------------------------------------------------"
  echo ""
}

function clonepull() {
  # clone, and pull if already cloned from url $1 into dir $2
  [ ! -d "$2/.git" ] && git clone --depth 1 "$1" "$2" || git -C "$2" pull origin master
}
