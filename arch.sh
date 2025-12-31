source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function getSudo() { pacman -Sy --noconfirm sudo; }

function prep() {
  # stuff that should only really need to be run on a new machine

  # set locale
  sudo sed -i '/en_US.UTF-8 UTF-8/s/#//g' /etc/locale.gen
  sudo locale-gen
  echo "LANG=en_US.UTF-8" | sudo tee /etc/locale.conf

  # nix prep, needs relogin to work
  sudo groupadd -f nix-users; sudo usermod -aG nix-users $(whoami)
  pac nix # needs relogin to work (for nixbld groups)

  # add 32bit
  grep '#\[multilib\]' \
    || echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" \
    |  sudo tee -a /etc/pacman.conf
  sudo sed -i -e '/#\[multilib\]/,+1s/^#//' /etc/pacman.conf # enable multilib
  sudo pacman -Sy

  setTimezone # prevents tz dialogue
  setHostname

  # set multi-user target
  sudo systemctl set-default multi-user.target

  # aur prep
  amp paru-bin
}

#===============================================================================
# POST-INSTALL CONFIGS
#===============================================================================

function install_steamgames() {
  pac steam; aur steamcmd
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

function packages() {
  # start nix daemon if service is not running
  # need to suppres stderr for nix daemon because it was printing blank outputs
  # when working interactively in a docker container
  systemctl is-active --quiet nix-daemon.service >/dev/null 2>&1 \
    && sudo systemctl restart nix-daemon.service \
    || sudo nix --extra-experimental-features nix-command daemon \
      >/dev/null 2>&1 &

  # nix
  sudo systemctl enable nix-daemon.service
  nxi nix nix-zsh-completions direnv nix-direnv nix-index nix-tree nh cachix

  # basics
  pac moreutils # has sponge command
  pac base linux linux-lts linux-firmware lsb-release
  pac linux-headers linux-lts-headers
  pac amd-ucode intel-ucode
  pac wget curl tar unzip git; pac util-linux base-devel
  pac python python-pip python-pipx uv
  pac rust # https://wiki.archlinux.org/title/Rust#Installation
  amp paru;
  pac terminus-font
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
  pac gcc make bear
  pac pass
  pac dhcpcd iwd networkmanager; { # networkmanager includes nmtui
    mkdir -p /etc/iwd
    echo '
      [General]
      EnableNetworkConfiguration=true

      [Network]
      NameResolvingService=systemd
    ' | awk '{$1=$1;print}' | sudo tee /etc/iwd/main.conf;

    # https://wiki.archlinux.org/title/NetworkManager#Configuring_MAC_address_randomization
    echo '
      [device]
      wifi.scan-rand-mac-address=no
    ' | awk '{$1=$1;print}' | sudo tee /etc/NetworkManager/conf.d/wifi-rand-mac.conf

    # https://wiki.archlinux.org/title/NetworkManager#Using_iwd_as_the_Wi-Fi_backend
    sudo systemctl disable iwd.service
    echo '
      [device]
      wifi.backend=iwd
    ' | awk '{$1=$1;print}' | sudo tee /etc/NetworkManager/conf.d/wifi-backend.conf

    # https://wiki.archlinux.org/title/NetworkManager#DHCP_client
    sudo systemctl disable dhcpcd.service
    echo '
      [main]
      dhcp=dhcpcd
    ' | awk '{$1=$1;print}' | sudo tee /etc/NetworkManager/conf.d/dhcp-client.conf
    sudo systemctl enable NetworkManager.service
    sudo systemctl enable systemd-networkd.service
  }
  pac cifs-utils # tool for mounding temp drives
  pac jq
  pac xsel xclip
  pac fzf ripgrep; nxi python313Packages.pyfzf
  pac neovim python-pynvim npm luarocks python-pip tree-sitter-cli vivify-git
  pac vim
  pac calc bc
  pac tmux

  # developer environments
  pac docker docker-buildx docker-compose; {
    sudo systemctl enable docker.service
    sudo groupadd -f docker
    sudo usermod -aG docker $(whoami)
  }

  aur autojump
  pac htop powertop
  pac openconnect; addSudoers /usr/bin/openconnect; addSudoers /usr/bin/pkill
  pac brightnessctl # brightness control
  pac redshift
  pac pipewire pipewire-pulse pipewire-alsa alsa-firmware wireplumber; {
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
  pac alacritty wezterm
  pac qutebrowser
  pac nyxt nuspell aspell
  pac firefox; install_ff_profile
  pac thunderbird; install_tb_profile
  pac maim     # screenshot utility
  pac ffmpeg   # screen record utility
  pac feh nsxiv xwallpaper # image viewer and wallpaper
  pac mpv      # video player
  pac zathura zathura-pdf-poppler
  aur joshuto-bin

  # color manipulation
  nxi pywal16 imagemagick wallust hellwal
  aur themecord walcord

  # gaming/school/work

  aur lifxlan-git; nxi python313Packages.aiolifx # LIFX lights

  # gaming
  pac steam; aur steamcmd geforce-infinity
  pac prismlauncher
  pac nvidia-open nvidia-open-lts lib32-nvidia-utils; {
    sudo sed -n '/^HOOKS/s/kms \| kms//gp' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
  }
  nxi shadps4

  pac gimp
  pac signal-desktop
  aur vesktop-bin
  nxi texlive.combined.scheme-full; {
    pac enscript    # converts textfile to postscript (use with ps2pdf)
    pac entr        # run arbitrary commands when files change, for live edit
    pac ghostscript # installs ps2pdf
    pac inkscape    # for latex drawings
  }
  nxi itd siglo # pinetime dev tools
  nxi librepcb verilator

  # robotics
  aur xctu coolterm-bin

  # TODO: not sure if I need this
  pac xdg-desktop-portal xdg-desktop-portal-gtk \
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
  pac foot

  # TODO: sort
  pac dunst
  pac imagemagick
  pac ncdu
  pac arp-scan net-tools # net-tools has arp command
  pac platformio-core
  pac refind grub efibootmgr # TODO: not sure what efibootmgr is for
  aur refind-theme-regular-git
  pac screen
  pac signal-desktop
  pac sudo
  pac fd # find files
  pac ueberzugpp openslide # images in terminal
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

  # macbook
  aur facetimehd-dkms

  # intel
  pac intel-media-sdk intel-media-driver
  pac vulkan-intel

  # system info
  pac inxi sysfsutils

  aur spotify; {
    pac spotify-player
    pac ncspot
  }
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
