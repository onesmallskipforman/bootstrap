source library.sh

#===============================================================================
# SYSTEM PREPS
#===============================================================================

function prepRoot() {
  # everything needed to run as user
  apt update -y; apt install -y sudo locales
  USER=$1
  useradd -m $USER || echo "User $USER exists"; passwd -d $USER
  echo "$USER ALL=(ALL) ALL" | tee /etc/sudoers.d/$USER
  chown $USER /home/$USER; chmod ug+w /home/$USER

  locale-gen en_US en_US.UTF-8
  update-locale LANG=en_US.UTF-8
  export LANG=en_US.UTF-8

  # sudo groupadd -r nixbld
  # for n in $(seq 1 10); do sudo useradd -c "Nix build user $n" \
  #     -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(which nologin)" \
  #     nixbld$n; done

  groupadd -f nix-users; usermod -aG nix-users $USER
  # chgrp nix-users /nix/var/nix/daemon-socket
  # chmod ug=rwx,o= /nix/var/nix/daemon-socket
}

function prep(){
  sudo apt update -y
  sudo apt full-upgrade -y
  sudo dpkg --add-architecture i386
  sudo ln -sfT /usr/share/zoneinfo/UTC /etc/localtime # prevents tz dialogue
  # https://askubuntu.com/a/1511983
  echo 'kernel.apparmor_restrict_unprivileged_userns=0' \
    | sudo tee /etc/sysctl.d/20-apparmor-allow-unprivileged-userns.conf
}

#===============================================================================
# INSTALLATIONS
#===============================================================================

function packages()
{
  # nix
  ain nix-bin nix-setup-systemd; {
    sudo systemctl enable nix-daemon.service
    echo "trusted-users = $(whoami)" | sudo tee -a /etc/nix/nix.conf
    sudo nix-daemon >/dev/null 2>&1 &
    # sudo nix --extra-experimental-features nix-command daemon >/dev/null 2>&1 &
    nix registry add nixpkgs $(pwd)
    nix flake update --flake nixpkgs
    nix profile upgrade --all
    nxi nix nix-zsh-completions direnv nix-direnv nix-index nix-tree nh cachix
  }

  # basics
  ain wget curl tar unzip software-properties-common ppa-purge dbus-broker dialog linux-generic
  ppa ppa:deadsnakes/ppa; ain python3 python3-pip python3-venv pipx
  # TODO: consider installing pipx with nix

  ain unminimize; yes | sudo unminimize
  ain man-db manpages texinfo
  nxi rustc git git-extras
  ain zsh zsh-syntax-highlighting zsh-autosuggestions; {
    sudo chsh -s /bin/zsh $(whoami)
    # TODO: make a little more robust
    # alternative: leave $HOME/.zshenv WITHOUT a symlink and have its
    # only contents be setting ZDOTDIR, then move all other env setup to
    # .zprofile (which can just point to or source a generic shell profile).
    echo 'export ZDOTDIR=$HOME/.config/zsh' | sudo tee -a /etc/zsh/zshenv >/dev/null
  }
  ain less
  ain systemd
  ain dhcpcd5 iwd network-manager; { # network-manager includes nmtui
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
  }
  ain cifs-utils # tool for mounding temp drives
  ain jq
  ain xsel xclip
  nxi fzf ripgrep
  nxi neovim python313Packages.pynvim nodejs-slim xsel xclip calc tree-sitter vim
  ain calc bc
  ain tmux

  # docker
  {
    # Add Docker's official GPG key:
    sudo apt-get update
    ain ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
  }
  ain docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin; {
    sudo systemctl enable docker.service
    sudo groupadd -f docker; sudo usermod -aG docker $USER
    ain iptables-persistent # TODO: might be needed for docker stuff
  }
  ain autojump
  ain htop
  ain openconnect; addSudoers /usr/bin/openconnect; addSudoers /usr/bin/pkill
  ain brightnessctl # brightness control
  nxi redshift # apt's redshift currently does not work
  ain pipewire pipewire-audio pipewire-pulse wireplumber; {
    ain pavucontrol pulsemixer # audio controllers
    ain pipewire-libcamera # not needed but the wireplumber binary complains
    ain firmware-sof-signed # not sure if needed
    ain alsa-utils
    systemctl --user enable pipewire pipewire-pulse wireplumber # covers both .service + .socket
  }
  ain bluez bluez-tools blueman rfkill playerctl; {
    rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
    sudo systemctl enable bluetooth.service
    # needed on ubuntu https://stackoverflow.com/a/68335639
    sudo systemctl disable blueman-mechanism.service
  }

  # Desktop Environment
  ain xorg xinit x11-utils # x11-utils contains xev
  ain xdotool # for grabbing window names
  ain xserver-xorg-input-libinput xinput # allows for sane trackpad expeirence
  ain arandr autorandr # xrandr caching and gui
  ain rofi; ghb newmanls/rofi-themes-collection
  ain bspwm sxhkd polybar picom dunst
  nxi polybarFull sxhkd neovim bspwm wget picom
  ain fontconfig; {
    nxi nerd-fonts.hack nerd-fonts.sauce-code-pro nerd-fonts.ubuntu-mono
    fc-cache -rv
  }


  # silly terminal scripts to show off
  ain figlet; ghb xero/figlet-fonts # For writing asciiart text
  ain tty-clock # terminal digial clock
  ain neofetch
  nxi asciiquarium pipes
  nxi macchina fastfetch # fetch
  ain chafa # terminal graphics TODO: find use case with file browser
  ghb stark/Color-Scripts # TODO: not in PATH
  nxi ueberzugpp

  # essential gui/advanced tui programs
  ain alacritty
  ppa ppa:mozillateam/ppa; {
    # https://askubuntu.com/a/1404401
    echo '
      Package: *
      Pin: release o=LP-PPA-mozillateam
      Pin-Priority: 1001

      Package: firefox
      Pin: version 1:1snap*
      Pin-Priority: -1
    ' | awk '{$1=$1;print}' | sudo tee /etc/apt/preferences.d/mozilla-firefox
    ain firefox
    # install_ff_profile
    # ffe darkreader ublock-origin vimium-ff youtube-recommended-videos \
    #   facebook-container news-feed-eradicator archlinux-wiki-search
    ain thunderbird
    # install_tb_profile
    # tbe darkreader tbsync eas-4-tbsync
  }
  ain qutebrowser
  ain maim     # screenshot utility
  ain ffmpeg   # screen record utility # TODO: consider fbcat
  ain feh sxiv # image viewer
  ain mpv      # video player
  ain zathura zathura-pdf-poppler
  nxi joshuto
  ain xsecurelock xscreensaver slock physlock vlock xss-lock # lockscreens. slock seems to be an alias to the package 'suckless-tools'

  # color manipulation
  nxi pywal16 python313Packages.colorthief imagemagick wallust hellwal

  # gaming/school/work
  ain ubuntu-drivers-common;
    ppa ppa:graphics-drivers/ppa; sudo ubuntu-drivers install
  deb https://zoom.us/client/latest/zoom_amd64.deb
  nxi slack
  nxi dmidecode
  nxi jira-cli-go
  nxi spotify spotify-qt spotify-player ncspot
  ain gimp
  ain can-utils

  # gp-saml-gui
  ppa ppa:yuezk/globalprotect-openconnect; ain globalprotect-openconnect
  addSudoers /usr/bin/gpclient

  nxi nyxt

  nxi calcure calcurse; ain ncal # calendars
  ain pass gnupg # for passwork management

  # needed for different interfaces to enter password
  # sudo update-alternatives --config pinentry
  # https://unix.stackexchange.com/a/759603
  ain pinentry-tty pinentry-curses pinentry-gnome3 pinetry-gtk pinentry-qt

  ain sshpass # non-interactive ssh password authentication
  ain cifs-utils # for mounting

  # nework scanning: https://askubuntu.com/a/377796
  ain nmap arp-scan net-tools # net-tools has arp

  ain speedtest-cli # speedtest.net by ookla
  ain xmlto # can convert xml to pdf

  ain haveged # random number generator
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
