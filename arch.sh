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

  sed -i '/en_US.UTF-8 UTF-8/s/#//g' /etc/locale.gen
  locale-gen
  echo "LANG=en_US.UTF-8" > /etc/locale.conf
}

function prep() {
  sed -i -e '/#\[multilib\]/,+1s/^#//' /etc/pacman.conf # enable multilib
  sudo pacman -Syu --noconfirm
  sudo ln -sfT /usr/share/zoneinfo/UTC /etc/localtime # prevents tz dialogue
}

#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function install_steamgames() {
  steam_install_game 1493710 # proton experiemental
  steam_install_game 2805730 # proton 9.0
  steam_install_game 252950  # rocket league
  # NOTE: installation is dependent on RL's proton version. Game needs to be
  # configured and run once before installing bakkesmod and after each time you
  # change RL's proton version
  aur --rebuild bakkesmod-steam; ln -sfT \
    $HOME/.config/bakkesmod \
    $HOME/.steam/steam/steamapps/compatdata/252950/pfx/drive_c/users/steamuser/AppData/Roaming/bakkesmod/bakkesmod/cfg
  installBakkesExtensions
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function packages()
{

  # https://wiki.archlinux.org/title/Pacman/Tips_and_tricks#With_version
  # list all explicitly installed packages
  # pacman -Qe
  # list all explcitly installed packages that arent required by other packages
  # pacman -Qe -t
  # list all foreign packages
  # pacman -Qm
  # list all native packages that are not direct or optional dependencies
  # pacman -Qent

  # basics
  pac base linux linux-firmware lsb-release
  pac intel-ucode # TODO: check hardware to determine intel-ucode or amd-ucode
  pac wget curl tar unzip git; pac python python-pip python-pipx go util-linux base-devel
  pac rust # https://wiki.archlinux.org/title/Rust#Installation
  amp yay-bin paru-bin;
  pac nix; {
    sudo usermod -aG nix-users $USER
    sudo systemctl enable --now nix-daemon.service
    nxi nix-zsh-completions direnv nix-direnv nix-index nix-tree nh cachix
  }
  pac terminus-font
  # aur guix
  pac zsh zsh-syntax-highlighting zsh-autosuggestions; {
    sudo chsh -s /bin/zsh $(whoami)
    # TODO: make a little more robust
    # TODO: alternative: leave $HOME/.zshenv WITHOUT a symlink and have its
    # only contents be setting ZDOTDIR, then move all other env setup to
    # .zprofile (which can just point to or source a generic shell profile).
    echo 'export ZDOTDIR=$HOME/.config/zsh' \
      | sudo tee -a /etc/zsh/zshenv >/dev/null
  }
  pac less which
  pac systemd
  pac reflector && sudo systemctl enable reflector.service
  pac man-db man-pages texinfo
  pac inetutils # has hostname commmand in arch
  pac gcc make cmake bazel bear
  pac pass
  pac dhcpcd iwd networkmanager; { # networkmanager includes nmtui
    mkdir -p /etc/iwd
    echo '
      [General]
      EnableNetworkConfiguration=true
    ' | awk '{$1=$1;print}' | sudo tee /etc/iwd/main.conf
    mkdir -p /etc/NetworkManager
    echo '
      # Configuration file for NetworkManager.
      # See "man 5 NetworkManager.conf" for details.

      [device]
      wifi.scan-rand-mac-address=no
      wifi.backend=iwd

      [Network]
      NameResolvingService=systemd
    ' | awk '{$1=$1;print}' | sudo tee /etc/NetworkManager/NetworkManager.conf
    sudo systemctl enable dhcpcd.service
    sudo systemctl enable iwd.service
    sudo systemctl enable NetworkManager.service
  }
  pac cifs-utils # tool for mounding temp drives
  pac jq
  pac xsel xclip
  pac fzf ripgrep; aur python-pyfzf
  pac neovim python-pynvim npm luarocks python-pip tree-sitter-cli
  pac vim
  pac calc bc
  pac tmux

  # developer environments
  pac docker docker-buildx docker-compose; {
    sudo systemctl enable docker.service
    sudo groupadd -f docker
    sudo usermod -aG docker $USER
  }

  aur autojump
  pac htop
  pac openconnect; addSudoers /usr/bin/openconnect; addSudoers /usr/bin/pkill
  pac brightnessctl # brightness control
  pac redshift
  pac pipewire pipewire-audio pipewire-pulse wireplumber; {
    pac pavucontrol pulsemixer # audio controllers
    pac pipewire-libcamera # not needed but the wireplumber binary complains
    pac sof-firmware # not sure if needed
    pac alsa-utils
    systemctl --user daemon-reload
    systemctl --user enable pipewire pipewire-pulse wireplumber # covers both .service + .socket
  }
  pac bluez bluez-utils bluez-tools blueman playerctl bluetui; aur bluetui-bin ; {
    rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
    sudo systemctl enable bluetooth.service
  }

  # Desktop Environment
  pac xorg-server xorg-xev xorg-xinit
  pac xorg-xsetroot # allows for setting cursor icon
  pac xdotool # for grabbing window names
  pac xf86-input-libinput xorg-xinput # allows for sane trackpad expeirence
  pac arandr autorandr # xrandr caching and gui
  pac rofi; aur rofi-themes-collection-git rofi-games
  pac bspwm sxhkd polybar picom
  pac fontconfig; {
    pac ttf-hack-nerd ttf-sourcecodepro-nerd ttf-ubuntu-mono-nerd
    aur ttf-ubraille
    sudo pacman -Rdd --noconfirm gnu-free-fonts
    fc-cache -rv
  }

  # silly terminal scripts to show off
  pac figlet; aur figlet-fonts # For writing asciiart text
  aur ascii-image-converter; cargo install ascii-gen
  pac fastfetch
  pac asciiquarium; aur tty-clock
  pac macchina; aur neofetch # fetch
  aur ascii-image-converter-bin
  aur color-scripts-git

  # essential gui/advanced tui programs
  pac alacritty
  pac qutebrowser
  pac firefox; install_ff_profile; {
    ffe darkreader ublock-origin vimium-ff youtube-recommended-videos \
      facebook-container news-feed-eradicator archlinux-wiki-search ublacklist
  }
  pac thunderbird; install_tb_profile; tbe darkreader tbsync eas-4-tbsync
  pac maim     # screenshot utility
  pac ffmpeg   # screen record utility
  pac feh sxiv # image viewer
  pac mpv      # video player
  pac zathura zathura-pdf-poppler
  aur joshuto-bin

  # color manipulation
  nxi pywal16 python313Packages.colorthief imagemagick wallust hellwal

  # gaming/school/work

  aur lifxlan-git; nxi python313Packages.aiolifx # LIFX lights

  # gaming
  pac steam; aur steamcmd
  pac prismlauncher; aur minecraft-launcher
  pac nvidia-open lib32-nvidia-utils; {
    sudo sed -n '/^HOOKS/s/kms \| kms//gp' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
  }
  aur shadps4-bin

  pac gimp
  pac signal-desktop
  aur spotify yet-another-spotify-tray-git; {
    aur spicetify spotify-player-full
    aur pywal-spicetify # TODO: add https://github.com/spicetify/spicetify-themes/tree/master via git
    pac ncspot
  }
  pac discord; aur vesktop-bin
  nxi texlive.combined.scheme-full; {
    pac enscript    # converts textfile to postscript (use with ps2pdf)
    pac entr        # run arbitrary commands when files change, for live edit
    pac ghostscript # installs ps2pdf
    pac inkscape    # for latex drawings
  }
  aur zoom slack-desktop
  aur scilab-bin
  pac arm-none-eabi-gcc; {
    pac arm-none-eabi-newlib libopencm3 stlink openocd
    aur stm32flash stm32cubeprog
  }
  aur itd-bin siglo # pinetime dev tools
  pac lib32-libpng12 lib32-fakeroot; aur quartus-130 modelsim-intel-starter


  # advent-of-code
  aur aoc-cli
  pac datamash # statistics tool
  aur rs-git # reshape data array
  aur csvtk-bin # CSV/TSV cli toolkit

  # robotics
  aur coolterm-bin tio # serial tools
  pac minicom picocom  # serial tools
  aur xctu

  # TODO: not sure if I need this
  pac xdg-desktop-portal \
    && systemctl --user enable xdg-desktop-portal

  # wayland
  pac wl-clipboard wlr-randr
  pac river
  pac hyprland xdg-desktop-portal-hyprland xdg-desktop-portal-wlr \
    && systemctl --user enable xdg-desktop-portal-hyprland
  pac wlsunset gammastep geoclue # color temperature
  pac swww # wallpaper
  pac waybar # bar
  pac fuzzel wofi # pickers
  aur lswt way-displays wideriver swhkd-git # TDB

  # TODO: sort
  pac dunst
  pac imagemagick
  pac ncdu
  pac arp-scan net-tools # net-tools has arp command
  pac platformio-core
  pac refind grub efibootmgr # TODO: not sure what efibootmgr is for
  pac screen
  pac signal-desktop
  pac sudo
  pac fd # find files
  pac ueberzugpp # images in terminal
  nxi joshuto
  nxi st # terminal
  pac time # time command
  pac spotifyd
  pac xorg-xauth
  pac xorg-xdpyinfo
  pac xorg-xmodmap
  pac xorg-xrandr
  pac xorg-xrdb
  pac guvcview
  pac cosmic-terminal # WIP terminal based on alacritty
  pac pacman-contrib # various pacman utilities
  pac openssh

  # TODO: not sure if i need these
  pac lshw
  pac noto-fonts
  pac qt6-multimedia
  pac sdl2-compat
  pac sndio
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
