source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prep() {
  sudo -V &>/dev/null || { pacman -Syu --noconfirm sudo; }
  ln -sf /usr/share/zoneinfo/UTC /etc/localtime
  echo 'wb-sgonzalez' > /etc/hostname # hostnamectl set-hostname <hostname>
  useradd -m skipper
  passwd  -d skipper
  passwd  -d nobody
  # TODO: rewrite so it doesn't keep appending the same line to the file
  echo 'skipper ALL=(ALL) ALL' | sudo tee -a /etc/sudoers.d/skipper
}

# function install_yay() {
#   pacman -S --needed --noconfirm git base-devel
#   local DIR=$(runuser -u nobody -- mktemp -u)
#   local URL=https://aur.archlinux.org/yay-bin.git
#   runuser -u nobody -- git clone $URL $DIR
#   ( cd $DIR; runuser -u nobody -- makepkg -s )
#   find $DIR -name "*.zst" | xargs sudo pacman -U --noconfirm
# }
# function install_yay() {
#   pacman -S --needed --noconfirm git wget tar base-devel
#   local DIR=$(runuser -u nobody -- mktemp -d)
#   local URL=https://aur.archlinux.org/cgit/aur.git/snapshot/yay-bin.tar.gz
#   wget -qO- $URL | runuser -u nobody -- tar xz -C $DIR --strip-components=1
#   ( cd $DIR; runuser -u nobody -- makepkg -s )
#   find $DIR -name "*.zst" | xargs sudo pacman -U --noconfirm
# }

# TODO: using makepkg -d might be preventing makedeps from being installed
# Consider just giving nobody some sudo nopasswd permissions
# this will require passwd -d AND adding nobody to sudoers
# ^definitely the latter
function install_aur() {
  pacman -S --needed --noconfirm wget tar base-devel
  local DIR=$(runuser -u nobody -- mktemp -d)
  local URL=https://aur.archlinux.org/cgit/aur.git/snapshot/$1.tar.gz
  wget -qO- $URL | runuser -u nobody -- tar xz -C $DIR --strip-components=1
  # -d required to prevent dep installs as nobody. pacman -U will cover deps
  ( cd $DIR; runuser -u nobody -- makepkg -si ) # -d )
  # find $DIR -name "*.zst" | xargs sudo pacman -U --noconfirm
}

# TODO: make aur function mappable
function aur() { install_aur $1; }

# TODO: needs work
# maybe stick with more minimal makepkg approach
# would need to find a way to browse AUR though
function yin() {
  runuser -l skipper -c "yay -S --noconfirm $@"
}

function packages()
{
  # basics
  pac wget curl tar unzip git python python-pipx util-linux base-devel
  aur yay-bin

  pac zsh zsh-syntax-highlighting zsh-autosuggestions && {
    sudo chsh -s /bin/zsh $(whoami)
    # ain vim-gtk xsel xclip # need a verison of vim with +clipboard enabled to properly yank
  }
  pac less which
  pac systemd-syscompat systemd
  pac gcc make cmake
  pac networkmanager # includes nmtui
  pac cifs-utils # tool for mounding temp drives
  pac jq
  pac xsel xclip
  fcn fzf && pac ripgrep
  pac nvim calc && pix pynvim && pac calc
  pac calc bc
  pac tmux
  pac autojump
  pac htop
  pac openconnect; addSudoers /usr/bin/openconnect; addSudoers /usr/bin/pkill
  pac brightnessctl # brightness control
  pac redshift
  pac pulseaudio alsa-utils pavucontrol pipewire # for audio controls # TODO: add systemctl config
  pac bluez bluez-tools blueman rfkill && {
    rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
    sudo service bluetooth start
    bluetoothctl power on
  }

  # Desktop Environment
  pac xorg
  pac xdotool   # for grabbing window names
  pac libinput  # allows for sane trackpad expeirence
  pac arandr    # for saving and loading monitor layouts
  pac autorandr # gui for managing monitor layouts
  pac rofi; aur rofi-themes-collection-git
  pac bspwm sxhkd polybar picom
  pac fontcofig; fcn fonts # TODO: is fontconfig required?

  # silly terminal scripts to show off
  pac figlet; aur figlet-fonts # For writing asciiart text
  # ain tty-clock # terminal digial clock
  pac neofetch
  pac asciiquarium
  pac fastfetch
  cargo install macchina # fetch
  aur color-scripts-git

  # essential gui/advanced tui programs
  pac alacritty
  pac firefox && ffe darkreader ublock-origin vimium-ff youtube-recommended-videos
  pac thunderbird && tbe darkreader tbsync eas-4-tbsync
  pac maim     # screenshot utility
  pac ffmpeg   # screen record utility
  pac feh sxiv # image viewer
  pac mpv      # video player
  pac zathura zathura-pdf-poppler && fcn zathura_pywal
  # fcn joshuto
  pix pywal16 && {
    pac imagemagick; pix colorthief haishoku colorz
    fcn go; go install github.com/thefryscorer/schemer2@latest
  }

  # gaming/school/work
  # fcn steam
  aur minecraft-launcher
  aur zoom
  aur ros-noetic-desktop-full
  aur ros-noetic-plotjuggler-ros
  aur ros2-iron-base
  pac spotify-launcher
  aur itd-bin; aur siglo # fcn waspos # pinetime dev tools
  aur quartus-130
  pac discord; aur vesktop-bin
  aur slack-desktop
  pac perl && fcn texlive && {
    pac enscript    # converts textfile to postscript (use with ps2pdf)
    pac entr        # run arbitrary commands when files change, for live edit
    pac ghostscript # installs ps2pdf
    pac inkscape    # for latex drawings
  }
}

bootstrap() {
  supersist
  bigprint "Prepping For Bootstrap"  ; prep
  bigprint "Copying dotfiles to home"; syncDots ~skipper
  bigprint "Installing Packages"     ; packages
  # bigprint "Configure OS"            ; config
  # bigprint "OS Config Complete. Restart Required"
}
