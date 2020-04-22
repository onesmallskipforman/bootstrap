#!/bin/sh

function basics() {
  sudo apt-get install -y \
    xserver-xorg-input-libinput \ # trackpad
    git
}

function redshift() {
  sudo add-apt-repository ppa:dobey/redshift-daily
  sudo apt-get update
  sudo apt-get install -y redshift
}

function nvim() {
  sudo add-apt-repository ppa:neovim-ppa/stable
  sudo apt-get update
  sudo apt-get install -y neovim
}

function i3() {
  sudo apt-get update && sudo apt-get -y dist-upgrade && \
  sudo apt-get install -y libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf xutils-dev libxcb-shape0-dev dh-autoreconf libtool

  mkdir -p $HOME/.local/src
  cd $HOME/.local/src

  git clone --recursive https://github.com/Airblader/xcb-util-xrm.git xcb-util-xrm
  ./autogen.sh
  make
  make install
  sudo ldconfig
  sudo ldconfig -p

  cd $HOME/.local/src
  git clone https://www.github.com/Airblader/i3 i3-gaps
  autoreconf --force --install
  rm -Rf build/
  mkdir build
  cd build/
  ../configure --prefix=/usr --sysconfdir=/etc
  make
  sudo make install
  which i3
  ls -l /usr/bin/i3
}

function alacritty() {
  # sudo apt-get install -y cmake libfreetype6-dev libfontconfig1-dev xclip

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh # rustup
  rustup override set stable
  rustup update stable

  cd $HOME/.local/src
  git clone https://github.com/jwilm/alacritty
  cd alacritty
  cargo install cargo-deb
  cargo deb --install -p alacritty

  # option 2
  apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3
  cargo build --release

  # man page
  sudo mkdir -p /usr/local/share/man/man1
  gzip -c alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null

  # zsh completions
  mkdir -p ${ZDOTDIR:-~}/.zsh_functions
  echo 'fpath+=${ZDOTDIR:-~}/.zsh_functions' >> ${ZDOTDIR:-~}/.zshrc
  cp extra/completions/_alacritty ${ZDOTDIR:-~}/.zsh_functions/_alacritty

}

function sublime() {
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt-get update
  sudo apt-get install -y sublime-text
}

function vscode() {
  curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
  sudo mv microsoft.gpg /etc/apt/trusted.gpg.d/microsoft.gpg
  sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
  sudo apt-get update
  sudo apt-get install -y code
}
