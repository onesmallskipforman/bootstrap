key "http://download.spotify.com/debian/pubkey.gpg"
key "http://packages.ros.org/ros.key"
# key "http://deb.nodesource.com/gpgkey/nodesource.gpg.key"

ppa "deb http://packages.ros.org/ros/ubuntu bionic main"       #
ppa "deb http://repository.spotify.com stable non-free"        #
# ppa "deb https://deb.nodesource.com/node_lts.x bionic main"    # node (for coc.vim)
ppa "ppa:dawidd0811/neofetch"                                  #
ppa "ppa:deadsnakes/ppa"                                       # up-to-date versions of python
ppa "ppa:dobey/redshift-daily"                                 #
ppa "ppa:drdeimosnn/survive-on-wm"                             # for bspwm, sxhkd, polybar
ppa "ppa:git-core/ppa"                                         # to get more recent update of git
ppa "ppa:inkscape.dev/stable"                                  # inkscape repo
ppa "ppa:mmstick76/alacritty"                                  # alacritty ppa
ppa "ppa:neovim-ppa/stable"                                    #
ppa "ppa:neovim-ppa/unstable"                                  # neovim latest unstable
ppa "ppa:ytvwld/asciiquarium"                                  #

apt "alsa-utils"                                               # for audio controls
apt "asciiquarium"                                             #
apt "autojump"                                                 #
apt "cmake"                                                    #
apt "compton"                                                  #
apt "curl"                                                     #
apt "feh"                                                      #
apt "gcc"                                                      #
apt "git"                                                      #
apt "htop"                                                     #
apt "inkscape"                                                 # for latex drawings
apt "libconfig-dev"                                            # picom dep
apt "libdbus-1-dev"                                            # picom dep
apt "libevdev-dev"                                             # picom dep
apt "libev-dev"                                                # picom dep
apt "libgl1-mesa-dev"                                          # picom dep
apt "libpcre2-dev"                                             # picom dep
apt "libpixman-1-dev"                                          # picom dep
apt "libx11-xcb-dev"                                           # picom dep
apt "libxcb1-dev"                                              # picom dep
apt "libxcb-composite0-dev"                                    # picom dep
apt "libxcb-damage0-dev"                                       # picom dep
apt "libxcb-image0-dev"                                        # picom dep
apt "libxcb-present-dev"                                       # picom dep
apt "libxcb-randr0-dev"                                        # picom dep
apt "libxcb-render0-dev"                                       # picom dep
apt "libxcb-render-util0-dev"                                  # picom dep
apt "libxcb-shape0-dev"                                        # picom dep
apt "libxcb-xfixes0-dev"                                       # picom dep
apt "libxcb-xinerama0-dev"                                     # picom dep
apt "libxext-dev"                                              # picom dep
apt "libc6:i386"                                               # modelsim dependency
apt "libncurses5:i386"                                         # modelsim dependency
apt "libstdc++6:i386"                                          # modelsim dependency
apt "libxext6:i386"                                            # modelsim dependency
apt "libxft2:i386"                                             # modelsim dependency
apt "make"                                                     #
apt "neofetch"                                                 #
apt "neovim"                                                   #
apt "polybar"                                                  # status bar
apt "pulseaudio"                                               # for audio controls
apt "python"                                                   # python 2.7 (needed for ROS)
apt "python3"                                                  # python 3.6
apt "python3-pip"                                              # pip3 for ubuntu's python3 (3.6)
apt "redshift"                                                 #
apt "ros-melodic-desktop-full"                                 #
apt "software-properties-common"                               # basic stuff like apt-add-repository command. probablly will be needed for lightweight installs
apt "spotify-client"                                           #
apt "sxiv"                                                     #
apt "tty-clock"                                                #
apt "uthash-dev"                                               # picom dep
apt "xautomation"                                              # for emulating keypresses to deal with firefox
apt "xbacklight"                                               # brightness control
apt "xdotool"                                                  # for grabbing window names (I use it to handle firefox keys)
apt "xserver-xorg-core"                                        # libinput dependency
apt "xserver-xorg-input-libinput"                              # allows for sane trackpad expeirence
apt "zsh"                                                      #
apt "zsh-syntax-highlighting"                                  #

git "https://github.com/aaron-williamson/base16-alacritty.git" # alacritty base 16 themes
git "https://github.com/eendroroy/alacritty-theme.git"         # alacritty themes
git "https://github.com/zsh-users/zsh-autosuggestions.git"     # zsh autosuggestions
git "https://github.com/dylanaraps/pfetch.git"                 # minimal fetch
git "https://github.com/junegunn/fzf.git"                      # fuzzy finder
git "https://github.com/xero/figlet-fonts.git"                 # figlet fonts
git "https://github.com/stark/Color-Scripts.git"               # colorscripts

pip "alacritty-colorscheme"                                    # alacritty color changer
pip "autopep8"                                                 # python style formatter
pip "flake8"                                                   # python linter
pip "pip"                                                      # installs pip
pip "pycodestyle"                                              # python style linter, requred by autopep8
pip "pylint"                                                   # python linter
pip "pynvim"                                                   # python support for neovim

ndf "DejaVuSansMono"                                           # nerd font
ndf "FiraCode"                                                 # nerd font
ndf "Hack"                                                     # nerd font
ndf "RobotoMono"                                               # nerd font
ndf "SourceCodePro"                                            # nerd font
ndf "UbuntuMono"                                               # nerd font

deb "https://github.com/haikarainen/light/releases/download/v1.2/light_1.2_amd64.deb"
deb "https://launcher.mojang.com/download/Minecraft.deb"
