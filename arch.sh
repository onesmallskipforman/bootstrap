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

  groupadd -f nix-users; usermod -aG nix-users $USER
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
  # nix
  pac nix; {
    sudo systemctl enable nix-daemon.service
    echo "trusted-users = $(whoami)" | sudo tee -a /etc/nix/nix.conf
    # sudo nix-daemon >/dev/null 2>&1 &
    sudo nix --extra-experimental-features nix-command daemon >/dev/null 2>&1 &
    nix registry add nixpkgs $(pwd)
    nix flake update --flake nixpkgs
    nix profile upgrade --all
    nxi nix-zsh-completions direnv nix-direnv nix-index nix-tree nh cachix home-manager
  }

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
  amp paru-bin;
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
  pac fzf ripgrep; nxi python313Packages.pyfzf
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
  pac htop powertop
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
  pac bluez bluez-utils bluez-tools blueman playerctl; {
    rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
    sudo systemctl enable bluetooth.service
    pac bluetui
  }

  # Desktop Environment
  pac xorg-server xorg-xev xorg-xinit xorg-xwininfo
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
  nxi ascii-image-converter; cargo install ascii-gen
  pac fastfetch
  pac asciiquarium; aur tty-clock
  pac macchina; aur neofetch # fetch
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
  nxi pywal16 imagemagick wallust hellwal
  aur themecord walcord

  # gaming/school/work

  aur lifxlan-git; nxi python313Packages.aiolifx # LIFX lights

  # gaming
  pac steam; aur steamcmd
  pac prismlauncher
  pac nvidia-open lib32-nvidia-utils; {
    sudo sed -n '/^HOOKS/s/kms \| kms//gp' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
  }
  nxi shadps4

  pac gimp
  pac signal-desktop
  aur spotify; {
    pac spotify-player
    pac ncspot
    nxi spotify-player
    nxi ncspot
    aur librespot
    nxi librespot

    # NOTE: current way to list arguments of a package function locally
    # not sure if there's an easier way
    # https://noogle.dev/f/lib/functionArgs
    # nixos.org/manual/nixpkgs/stable/#function-library-lib.trivial.functionArgs
    # nix-channel --add https://nixos.org/channels/nixpkgs-unstable
    # nix-channel --update
    # nix eval --impure --expr 'with import <nixpkgs> { }; lib.functionArgs spotify-player.override' --json
  }
  pac discord; aur vesktop-bin
  nxi texlive.combined.scheme-full; {
    pac enscript    # converts textfile to postscript (use with ps2pdf)
    pac entr        # run arbitrary commands when files change, for live edit
    pac ghostscript # installs ps2pdf
    pac inkscape    # for latex drawings
  }
  # aur zoom slack-desktop
  nxi scilab-bin
  pac arm-none-eabi-gcc; {
    pac arm-none-eabi-newlib libopencm3 stlink openocd
    nxi stm32flash
    aur stm32cubeprog
  }
  nxi itd siglo # pinetime dev tools
  pac lib32-libpng12 lib32-fakeroot; aur quartus-130 modelsim-intel-starter


  # advent-of-code
  nxi aoc-cli
  pac datamash # statistics tool
  aur rs-git # reshape data array
  aur csvtk-bin # CSV/TSV cli toolkit

  # robotics
  aur coolterm-bin; nxi tio # serial tools
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
  nxi lswt # list wayland toplevels
  nxi wideriver # bspwm-like layout for river
  nxi way-displays # like arandr

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
  pac noto-fonts noto-fonts-emoji
  pac qt6-multimedia
  pac sdl2-compat
  pac sndio


  pac parted gparted gptfdisk testdisk lvm2 # disk utilities

  pac augeas # for editing conf files


  pac lemurs # custom display login manager
  pac swaylock waylock # lock screens
  pac wmctrl # interact with EMWH compatible X window managers
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
