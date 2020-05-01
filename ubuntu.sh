# shell functions for configuring and installing various programs on Ubuntu

#===============================================================================
# SYSTEM PREP
#===============================================================================

function os_prep() {
  bigprint "Prepping OS"
  sudo apt-get install -y git curl
  echo "OS Prep Complete."
}

function key_prep() {
  bigprint "Prepping Keys for Installations"

  # Prep Sublime
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

  # Prep VSCode
  # option 1 - need to test
  # wget -q https://packages.microsoft.com/keys/microsoft.asc -O- | sudo apt-key add -
  # sudo add-apt-repository "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main"

  # option 2
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function pkg_install() {
  # Install Apt Package Repos and Packages
  bigprint "Installing Packages."
  sudo apt-get update -y && sudo apt-get dist-upgrade -y

  grep '^repo' $APT_BUNDLE_FILE  \
    | sed 's/^[^"]*"//; s/".*//' \
    | xargs -n1 sudo add-apt-repository -y
  sudo apt-get update -y && sudo apt-get dist-upgrade -y

  grep '^apt'  $APT_BUNDLE_FILE  \
    | sed 's/^[^"]*"//; s/".*//' \
    | xargs sudo apt-get install -y
  sudo apt-get update -y && sudo apt-get dist-upgrade -y
}

function cargo_install() {
  bigprint "Installing Cargo Packages"
  which rustup &>/dev/null || (
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    rustup override set stable
  )
  rustup update stable
  source $HOME/.cargo/env
  cat "$HOME/.config/cargo/cargo_ubuntu.txt" | xargs -n1 cargo install --git
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
  done < "$HOME/.config/git/repos_ubuntu.txt"
  echo "Repo Cloning Complete."
}

#===============================================================================
# APP CONFIGS/SETUPS
#===============================================================================

function os_config() {
  sudo chsh -s /bin/zsh
  hostnamectl set-hostname SkippersMPB
}

function wm_config() {
  cd $HOME/.local/src/xcb-util-xrm
  ./autogen.sh
  make
  sudo make install
  sudo ldconfig
  sudo ldconfig -p

  cd $HOME/.local/src/i3
  autoreconf --force --install
  mkdir build
  cd build/
  ../configure --prefix=/usr --sysconfdir=/etc
  make
  sudo make install
}
