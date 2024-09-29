source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prepRoot() {
  pacman -Syu --noconfirm sudo; pacman -Fy --noconfirm
  USER=$1
  useradd -m $USER; passwd -d $USER
  echo "$USER ALL=(ALL) ALL" | tee -a /etc/sudoers.d/$USER
  chown $USER /home/$USER; chmod ug+w /home/$USER
}

function prep() {
  # NOTE: does not cover edge cases for .conf contents
  cat /etc/pacman.conf \
    | grep -qPzo "(?m)^\[multilib\][^]]*^Include = /etc/pacman.d/mirrorlist" \
    || echo -e '[multilib]\nInclude = /etc/pacman.d/mirrorlist' \
      | sudo tee -a /etc/pacman.conf >/dev/null
  sudo pacman -Syu --noconfirm
  sudo ln -sf /usr/share/zoneinfo/UTC /etc/localtime # prevents tz dialogue
}

#===============================================================================
# CUSTOM INSTALL FUNCTIONS
#===============================================================================

function install_steamgames() {
  steam_install_game 1493710 # proton experiemental
  steam_install_game 2805730 # proton 9.0
  steam_install_game 252950  # rocket league
  aur bakkesmod-steam
  installBakkesExtensions
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function packages()
{
  # basics
  pac wget curl tar unzip git python python-pipx go util-linux base-devel
  pac nix && systemctl enable nix-daemon.service
  amp yay-bin paru-bin
  pac zsh zsh-syntax-highlighting zsh-autosuggestions \
    && sudo chsh -s /bin/zsh $(whoami)
  pac less which
  pac systemd
  pac man-db man-pages texinfo
  pac inetutils
  pac gcc make cmake bazel
  pac pass
  pac dhcpcd iwd networkmanager && { # networkmanager includes nmtui
    echo '
      [General]
      EnableNetworkConfiguration=true
    ' | awk '{$1=$1;print}' | sudo tee /etc/iwd/main.conf
    echo '
      # Configuration file for NetworkManager.
      # See "man 5 NetworkManager.conf" for details.

      [device]
      wifi.scan-rand-mac-address=no
      wifi.backend=iwd

      [Network]
      NameResolvingService=systemd
    ' | awk '{$1=$1;print}' | sudo tee /etc/NetworkManager/NetworkManager.conf
    systemctl enable dhcpcd.service
    systemctl enable iwd.service
    systemctl enable NetworkManager.service
  }
  pac cifs-utils # tool for mounding temp drives
  pac jq
  pac xsel xclip
  pac fzf ripgrep
  pac neovim python-pynvim npm luarocks python-pip
  pac calc bc
  pac tmux
  pac docker && {
    systemctl enable docker.service
    sudo groupadd docker
    sudo usermod -aG docker $USER
  }
  aur autojump
  pac htop
  pac openconnect; addSudoers /usr/bin/openconnect; addSudoers /usr/bin/pkill
  pac brightnessctl # brightness control
  pac redshift
  pac pavucontrol pulsemixer; fcn pipewire # for audio controls
  pac pipewire pipewire-audio pipewire-pulse wireplumber ; {
    pac pavucontrol pulsemixer # audio controllers
    pac pipewire-libcamera # not needed but the wireplumber binary complains
    pac sof-firware # not sure if needed
    systemctl --user daemon-reload
    systemctl --user disable pulseaudio # covers both .service + .socket
    systemctl --user mask    pulseaudio
    systemctl --user enable  pipewire pipewire-pulse wireplumber
  }
  pac bluez bluez-utils blueman rfkill playerctl && {
    rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
    sudo systemctl daemon-reload
    sudo systemctl start bluetooth.service
    sudo systemctl enable bluetooth.service
    bluetoothctl power on
  }

  # Desktop Environment
  pac xorg xorg-xev xorg-xinit
  pac xdotool # for grabbing window names
  pac libinput # allows for sane trackpad expeirence
  pac arandr autorandr # xrandr caching and gui
  pac rofi; aur rofi-themes-collection-git
  pac bspwm sxhkd polybar picom
  pac ttf-hack-nerd ttf-sourcecodepro-nerd ttf-ubuntu-mono-nerd; aur ttf-ubraille \
    && sudo pacman -Rdd --noconfirm gnu-free-fonts

  # silly terminal scripts to show off
  pac figlet; aur figlet-fonts # For writing asciiart text
  aur ascii-image-converter; cargo install ascii-gen
  pac neofetch
  pac fastfetch
  pac asciiquarium; aur tty-clock
  aur macchina-bin # fetch
  aur color-scripts-git

  # essential gui/advanced tui programs
  pac alacritty
  pac qutebrowser
  pac firefox && fcn ff_profile && {
    ffe darkreader ublock-origin vimium-ff youtube-recommended-videos \
      facebook-container news-feed-eradicator archlinux-wiki-search
  }
  pac thunderbird && fcn tb_profile && tbe darkreader tbsync eas-4-tbsync
  pac maim     # screenshot utility
  pac ffmpeg   # screen record utility
  pac feh sxiv # image viewer
  pac mpv      # video player
  pac zathura zathura-pdf-poppler && fcn zathura_pywal
  aur joshuto-bin
  pix pywal16 && {
    pac imagemagick; pix colorthief haishoku colorz
    GOPATH=$HOME/.local/share/go go install github.com/thefryscorer/schemer2@latest
    wal --cols16 lighten --backend wal
  }

  # gaming/school/work
  pac steam; aur steamcmd
  aur minecraft-launcher
  pac nvidia-open lib32-nvidia-utils && {
    sudo sed -n '/^HOOKS/s/kms \| kms//gp' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
  }
  aur signal-desktop
  pac spotify-launcher
  pac discord; aur vesktop-bin
  pac perl && fcn texlive && {
    pac enscript    # converts textfile to postscript (use with ps2pdf)
    pac entr        # run arbitrary commands when files change, for live edit
    pac ghostscript # installs ps2pdf
    pac inkscape    # for latex drawings
  }
  aur zoom slack-desktop
  aur scilab-bin
  aur arm-none-eabi-gcc stm32cubeprog; pac libopenecm3 stlink openocd;
  # sudo usermod -aG uucp skipper # for access to /dev/ttyUSB0
  # aur quartus-130 # FIX: broken build
  # aur itd-bin siglo # pinetime dev tools # TODO:lengthy builds
}

#===============================================================================
# MAIN BOOTSTRAP FUNCTION
#===============================================================================

function bootstrap() {
  supersist
  bigprint "Prepping For Bootstrap"  ; prep
  bigprint "Copying dotfiles to home"; syncDots
  bigprint "Installing Packages"     ; packages
  bigprint "Configure OS"            ; config
  bigprint "OS Config Complete. Restart Required"
}
