#!/bin/sh

function other() {
  sudo apt-get install -y arandr # for setting display configs
}

function ubuntu_prep() {
  hostnamectl set-hostname SkippersMPB
}

function ubuntu_config() {
  sudo chsh -s /bin/zsh
  sudo apt-get install -y xserver-xorg-input-libinput
}

function gitstuff() {
  sudo add-apt-repository -y ppa:git-core/ppa
  sudo apt-get update
  sudo apt-get install -y git
}

function zsh() {
  sudo apt-get install -y zsh zsh-syntax-highlighting autojump zsh-autosuggestions
  git -C "$HOME/.local/src" clone https://github.com/zsh-users/zsh-autosuggestions.git
}

function redshift() {
  sudo add-apt-repository -y ppa:dobey/redshift-daily
  sudo apt-get update
  sudo apt-get install -y redshift
}

function nvim() {
  sudo add-apt-repository -y ppa:neovim-ppa/stable
  sudo apt-get update
  sudo apt-get install -y neovim
}

function i3() {
  sudo apt-get update && sudo apt-get -y dist-upgrade && \
  sudo apt-get install -y libxcb1-dev libxcb-keysyms1-dev libpango1.0-dev libxcb-util0-dev libxcb-icccm4-dev libyajl-dev libstartup-notification0-dev libxcb-randr0-dev libev-dev libxcb-cursor-dev libxcb-xinerama0-dev libxcb-xkb-dev libxkbcommon-dev libxkbcommon-x11-dev autoconf xutils-dev libxcb-shape0-dev dh-autoreconf libtool

  mkdir -p $HOME/.local/src
  cd $HOME/.local/src

  git clone --recursive https://github.com/Airblader/xcb-util-xrm.git xcb-util-xrm
  cd xcb-util-xrm
  ./autogen.sh
  make
  sudo make install
  sudo ldconfig
  sudo ldconfig -p

  cd $HOME/.local/src
  git clone https://www.github.com/Airblader/i3 i3-gaps
  cd i3-gaps
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

function i3blocks() {
  sudo apt-get update
  sudo apt-get install i3blocks
}

function alacritty_install() {
  sudo apt-get install -y cmake libfreetype6-dev libfontconfig1-dev xclip

  sudo apt-get install -y curl

  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y # rustup
  rustup override set stable
  rustup update stable
  source $HOME/.cargo/env

  mkdir -p $HOME/.local/src
  cd $HOME/.local/src
  git clone https://github.com/alacritty/alacritty alacritty
  cd alacritty

  apt-get install cmake pkg-config libfreetype6-dev libfontconfig1-dev libxcb-xfixes0-dev python3

  # option 1
  cargo install cargo-deb
  cargo deb --install -p alacritty

  # option 2 (something is not working here)
  # cargo build --release

  # option 3
  # cargo install --git https://github.com/alacritty/alacritty

  # option 4
  # make binary

  # man page
  sudo mkdir -p /usr/local/share/man/man1
  gzip -c extra/alacritty.man | sudo tee /usr/local/share/man/man1/alacritty.1.gz > /dev/null

  # zsh completions
  # mkdir -p ${ZDOTDIR:-~}/.zsh_functions
  # echo 'fpath+=${ZDOTDIR:-~}/.zsh_functions' >> ${ZDOTDIR:-~}/.zshrc
  # cp extra/completions/_alacritty ${ZDOTDIR:-~}/.zsh_functions/_alacritty

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

function baskerville() {
  sudo apt-get install -y git \
                      xcb \
                      libxcb-util0-dev \
                      libxcb-ewmh-dev \
                      libxcb-randr0-dev \
                      libxcb-icccm4-dev \
                      libxcb-keysyms1-dev \
                      libxcb-xinerama0-dev \
                      libasound2-dev \
                      gcc \
                      make \
                      libxcb-xtest0-dev \
                      libxft-dev \
                      libx11-xcb-dev

  cd  ~/.local/src
  # git clone https://github.com/baskerville/bspwm.git
  git clone https://github.com/baskerville/sxhkd.git
  # git clone https://github.com/baskerville/sutils.git
  # git clone https://github.com/baskerville/xtitle.git
  # git clone https://github.com/baskerville/xdo.git

  # cd  ~/development/github.com/baskerville
  # cd bspwm/ && make && sudo make install
  cd sxhkd && make && sudo make install
  # cd ../sutils/ && make && sudo make install
  # cd ../xtitle/ && make && sudo make install
  # cd ../xdo/ && make && sudo make install

  # patched lemonbar
  # cd ~/development/github.com/krypt-n
  # cd !:1
  # git clone https://github.com/krypt-n/bar.git
  # cd bar && make && sudo make install
}
