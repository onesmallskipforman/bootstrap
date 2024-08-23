source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prep() {
  which sudo || { pacman -Sy && pacman -Sy --noconfirm sudo; }

  # local HN="Skipper"
  # hostnamectl set-hostname $HN
}

function packages()
{
  # basics
  pac
  pac util-linux
  pac less
  pac git

  # pac tzdata
  pac zsh zsh-syntax-highlighting zsh-autosuggestions && {
    sudo chsh -s /bin/zsh $(whoami) # ghb zsh-users/zsh-autosuggestions # TODO: consider getting both of these straight from github
    # ain vim-gtk xsel xclip # need a verison of vim with +clipboard enabled to properly yank
  }
  pac python && pin pipx
  fcn guix
  pac systemd-syscompat systemd
  pac xorg
  pac gcc
  pac make cmake
  pac wget curl
  pac networkmanager # i think this has nmtui # TODO: need to address that you won't be able to use this script without wifi. maybe do some prep step
  pac cifs-utils # tool for mounding temp drives
  pac jq
  pac xsel xclip
  ain bluez bluez-tools blueman rfkill && {
    # sudo service bluetooth start
  #   rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
  #   fcn bluez
  #   fcn itd
  #   fcn waspos
  #   fcn siglo
  #   bluetoothctl power on
  }

  # Desktop Environment
  pac brightnessctl # brightness control
  # pac xdotool # for grabbing window names (I use it to handle firefox keys)
  # ain xserver-xorg-core # libinput dependency
  # ain xserver-xorg-input-libinput # allows for sane trackpad expeirence
  # ain pulseaudio alsa-utils pavucontrol && fcn pipewire # for audio controls
  pac arandr # for saving and loading monitor layouts
  pac autorandr # gui for managing monitor layouts
  pac rofi; ghb newmanls/rofi-themes-collection
  pac bspwm sxhkd
  pac polybar
  pac redshift
  pac picom # fcn picom # newer version will have animations
  pac fontcofig; fcn fonts # TODO: is fontconfig required?

  # silly terminal scripts to show off
  pac figlet; ghb xero/figlet-fonts # For writing asciiart text
  # ain tty-clock # terminal digial clock
  pac neofetch
  pac asciiquarium
  pac fastfetch
  # TODO: https://github.com/Macchina-CLI/macchina/wiki/Installation#arch-linux
  cargo install macchina # fetch
  ghb stark/Color-Scripts # colorscripts  # TODO: may need to check this shows up in path

  # essential gui/advanced tui programs
  pac maim # screenshot utility
  pac ffmpeg # screen record utility
  pac firefox
  pac feh sxiv # image viewer
  pac mpv # video player
  pac alacritty
  pac nvim && pin pynvim && fcn node20 && ain calc # TODO: not sure if i need xsel and/or xclip here
  pac tmux # fcn tmux
  pac fzf && { # ghb junegunn/fzf && ~/.local/src/fzf/install --all --xdg --completion
    pac ripgrep # fuzzy finder
  }
  pac autojump
  pac htop
  pac openconnect; addSudoers /usr/bin/openconnect, /usr/bin/pkill
  # fcn texlive && {
  #   ain enscript    # converts textfile to postscript (use with ps2pdf)
  #   ain entr        # run arbitrary commands when files change, for live edit
  #   ain ghostscript # installs ps2pdf
  #   ppa ppa:inkscape.dev/stable && ain inkscape # for latex drawings
  # }

  # gin nyxt
  # ain zathura zathura-pdf-poppler && fcn zathura_pywal
  # deb 'https://github.com/wez/wezterm/releases/download/20240203-110809-5046fc22/wezterm-20240203-110809-5046fc22.Ubuntu20.04.deb'
  # fcn joshuto

  # ghb eylles/pywal16 && {
  #   pin ~/.local/src/pywal16
  #   ain imagemagick
  #   pin colorthief
  #   pin haishoku
  #   pin colorz
  #   fcn go
  #   go install github.com/thefryscorer/schemer2@latest
  # }


  #
  # ain firefox && {
  #   install_ff_extension darkreader
  #   install_ff_extension ublock-origin
  #   install_ff_extension vimium-ff
  #   install_ff_extension youtube-recommended-videos
  # }
  # ain thunderbird && {
  #   install_tb_extension darkreader
  #   install_tb_extension tbsync
  #   install_tb_extension eas-4-tbsync
  # }
  # ain thunderbird

  # gaming/school/work
  # fcn steam
  # deb https://launcher.mojang.com/download/Minecraft.deb
  # deb https://zoom.us/client/latest/zoom_amd64.deb
  # fcn ros
  # fcn spotify

  # fcn "quartus"
  # TODO: add discord
  # TODO: add slack
}
