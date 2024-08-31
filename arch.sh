source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prepRoot() {
  pacman -Syu --noconfirm sudo
  USER=$1
  useradd -m $USER; passwd -d $USER
  echo "$USER ALL=(ALL) ALL" | tee -a /etc/sudoers.d/$USER
  chown $USER /home/$USER; chmod ug+w /home/$USER
}

function prep() {
  # TODO: if you run pacman -Sy after multilib without --noconfirm, you get
  # some ttf font dialogue. Figure out what this is.
  # TODO: figure out how to not add this multiple times
  echo -e '[multilib]\nInclude = /etc/pacman.d/mirrorlist' \
    | sudo tee -a /etc/pacman.conf >/dev/null
  sudo pacman -Syu --noconfirm
  sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime # prevents tz dialogue
}

function config() {
  USR=skipper; HN=wb-sgonzalez
  # TODO: need to change shell too with chsh
  # TODO: this won't work while in runuser as the old user being renamed
  # usermod -l $USR -m -d $(echo $HOME | sed "s;$(whoami);$USR;g") $(whoami)
  # sudo groupmod -n $USR $(whoami)
  # sudo mv /etc/sudoers.d/$(whoami) /etc/sudoers.d/$USR
  sudo ln -sfn /usr/share/zoneinfo/$(curl https://ipapi.co/timezone) /etc/localtime
  echo $HN | sudo tee /etc/hostname >/dev/null # hostnamectl set-hostname $HN
  sudo systemctl set-default multi-user.target
}

function packages()
{
  # basics
  pac wget curl tar unzip git python python-pipx go util-linux base-devel
  amp yay-bin paru-bin
  pac zsh zsh-syntax-highlighting zsh-autosuggestions && {
    sudo chsh -s /bin/zsh $(whoami)
    # ain vim-gtk xsel xclip # need a verison of vim with +clipboard enabled to properly yank
  }
  pac less which
  pac systemd-syscompat systemd
  pac gcc make cmake bazel
  pac networkmanager # includes nmtui
  pac cifs-utils # tool for mounding temp drives
  pac jq
  pac xsel xclip
  pac fzf ripgrep
  pac nvim python-pynvim # pix pynvim
  pac calc bc
  pac tmux
  pac autojump htop
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
  pac xorg xorg-xev xorg-xinit
  pac xdotool # for grabbing window names
  pac libinput # allows for sane trackpad expeirence
  pac arandr autorandr # xrandr caching and gui
  pac rofi; aur rofi-themes-collection-git
  pac bspwm sxhkd polybar picom
  pac ttf-hack-nerd ttf-sourcecodepro-nerd ttf-ubuntu-mono-nerd

  # silly terminal scripts to show off
  pac figlet; aur figlet-fonts # For writing asciiart text
  pac neofetch
  pac fastfetch
  pac tty-clock asciiquarium
  aur macchina-bin # fetch
  aur color-scripts-git

  # essential gui/advanced tui programs
  pac alacritty
  pac firefox     && fcn ff_profile && ffe darkreader ublock-origin vimium-ff youtube-recommended-videos
  pac thunderbird && fcn tb_profile && tbe darkreader tbsync eas-4-tbsync
  pac maim     # screenshot utility
  pac ffmpeg   # screen record utility
  pac feh sxiv # image viewer
  pac mpv      # video player
  pac zathura zathura-pdf-poppler && fcn zathura_pywal
  aur joshuto-bin
  pix pywal16 && {
    pac imagemagick; pix colorthief haishoku colorz
    go install github.com/thefryscorer/schemer2@latest
  }

  # gaming/school/work
  pac steam
  aur minecraft-launcher
  fcn drivers
  # aur zoom # TODO: lengthy compression
  aur signal-desktop
  pac spotify-launcher
  # aur itd-bin siglo # fcn waspos # pinetime dev tools # TODO:itd-bin is a lengthy build from scratch
  # aur scilab-bin # TODO: lengthy build
  # aur quartus-130 # FIX: broken build
  pac discord; aur vesktop-bin
  # aur slack-desktop # TODO: lengthy compression
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
  bigprint "Copying dotfiles to home"; syncDots
  bigprint "Installing Packages"     ; packages
  bigprint "Configure OS"            ; config
  bigprint "OS Config Complete. Restart Required"
}
