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
  # NOTE: does not cover edge cases for .conf contents
  cat /etc/pacman.conf \
    | grep -qPzo "(?m)^\[multilib\][^]]*^Include = /etc/pacman.d/mirrorlist" \
    || echo -e '[multilib]\nInclude = /etc/pacman.d/mirrorlist' \
      | sudo tee -a /etc/pacman.conf >/dev/null
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
  # installation is dependent on RL's proton version. Game needs to be
  # configured and run once before installing bakkesmod and after
  # each time you change RL's proton version
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
  pac wget curl tar unzip git python python-pipx go util-linux base-devel
  pac rust # https://wiki.archlinux.org/title/Rust#Installation
  amp yay-bin paru-bin; pac nix; sudo usermod -aG nix-users $USER
  # aur guix
  pac zsh zsh-syntax-highlighting zsh-autosuggestions; {
    sudo chsh -s /bin/zsh $(whoami)
    # TODO: make a little more robust
    # TODO: alternative: leave $HOME/.zshenv WITHOUT a symlink and have its
    # only contents be setting ZDOTDIR, then move all other env setup to
    # .zprofile (which can just point to or source a generic shell profile).
    echo 'export ZDOTDIR=$HOME/.config/zsh' | sudo tee -a /etc/zsh/zshenv >/dev/null
  }
  pac less which
  pac systemd
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
  pac fzf ripgrep
  pac neovim python-pynvim npm luarocks python-pip tree-sitter-cli
  pac calc bc
  pac tmux
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
    pac sof-firware # not sure if needed
    pac alsa-utils
    systemctl --user daemon-reload
    systemctl --user enable  pipewire pipewire-pulse wireplumber # covers both .service + .socket
  }
  pac bluez bluez-utils blueman rfkill playerctl; {
    rfkill | awk '/hci0/{print $1}' | xargs rfkill unblock
    sudo systemctl enable bluetooth.service
  }

  # Desktop Environment
  pac xorg xorg-xev xorg-xinit
  pac xdotool # for grabbing window names
  pac xf86-input-libinput xorg-xinput # allows for sane trackpad expeirence
  pac arandr autorandr # xrandr caching and gui
  pac rofi; aur rofi-themes-collection-git
  pac bspwm sxhkd polybar picom
  pac ttf-hack-nerd ttf-sourcecodepro-nerd ttf-ubuntu-mono-nerd; aur ttf-ubraille; {
    sudo pacman -Rdd --noconfirm gnu-free-fonts
  }

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
  pac firefox; fcn ff_profile; {
    ffe darkreader ublock-origin vimium-ff youtube-recommended-videos \
      facebook-container news-feed-eradicator archlinux-wiki-search ublacklist
  }
  pac thunderbird; fcn tb_profile; tbe darkreader tbsync eas-4-tbsync
  pac maim     # screenshot utility
  pac ffmpeg   # screen record utility
  pac feh sxiv # image viewer
  pac mpv      # video player
  pac zathura zathura-pdf-poppler; fcn zathura_pywal
  aur joshuto-bin
  pxi 'pywal16[all]'; {
    ain imagemagick; coi okthief; goi github.com/thefryscorer/schemer2@latest
  }
  aur wallust

  # gaming/school/work
  pac steam; aur steamcmd
  pac prismlauncher
  pac nvidia-open lib32-nvidia-utils; {
    sudo sed -n '/^HOOKS/s/kms \| kms//gp' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
  }
  pac gimp
  aur signal-desktop
  aur spotify yet-another-spotify-tray-git; {
    aur spicetify spotify-player-full
    pac ncspot
  }
  pac discord; aur vesktop-bin
  pac perl; get_texlive; {
    pac enscript    # converts textfile to postscript (use with ps2pdf)
    pac entr        # run arbitrary commands when files change, for live edit
    pac ghostscript # installs ps2pdf
    pac inkscape    # for latex drawings
  }
  aur zoom slack-desktop
  aur scilab-bin
  aur arm-none-eabi-gcc stm32cubeprog; pac libopenecm3 stlink openocd
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
