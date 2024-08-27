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
  # TODO: rewrite so it doesn't keep appending the same line to the file
  echo 'skipper ALL=(ALL) ALL' | sudo tee -a /etc/sudoers.d/skipper
}

function install_yay() {
  pacman -S --needed --noconfirm git base-devel
  local DIR=$(runuser -u nobody -- mktemp -d)
  runuser -u nobody -- git -C $DIR clone https://aur.archlinux.org/yay-bin.git repo
  ( cd $DIR/repo; runuser -u nobody -- makepkg -s )
  find $DIR -name "*.zst" | xargs sudo pacman -U --noconfirm
}

# TODO: needs work
function yin() {
  runuser -l skipper -c "yay -S --noconfirm $@"
}

function packages()
{
  # basics
  pac wget curl tar unzip git python python-pipx
  pac util-linux base-devel
  fcn yay

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
  pac rofi; ghb newmanls/rofi-themes-collection
  pac bspwm sxhkd polybar picom
  pac fontcofig; fcn fonts # TODO: is fontconfig required?

  # silly terminal scripts to show off
  pac figlet; ghb xero/figlet-fonts # For writing asciiart text
  # ain tty-clock # terminal digial clock
  pac neofetch
  pac asciiquarium
  pac fastfetch
  cargo install macchina # fetch
  ghb stark/Color-Scripts # colorscripts

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
  # deb https://launcher.mojang.com/download/Minecraft.deb
  # deb https://zoom.us/client/latest/zoom_amd64.deb
  # fcn ros
  pac spotify-launcher
  fcn itd waspos # siglo # pinetime dev tools
  # fcn quartus
  pac discord
  # TODO: add slack
  pac perl && fcn texlive && {
    pac enscript    # converts textfile to postscript (use with ps2pdf)
    pac entr        # run arbitrary commands when files change, for live edit
    pac ghostscript # installs ps2pdf
    pac inkscape # for latex drawings
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
