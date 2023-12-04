source library.sh

prep(){
    sudo softwareupdate -irR && xcode-select --install
    which brew &>/dev/null || (sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | NONINTERACTIVE=1 /bin/bash -c )
    sudo spctl --master-disable # allow apps downloaded from anywhere
}

config() {
    local alias dw='defaults write'

    # disable time machine
    sudo tmutil disable

    # Set computer name
    sudo scutil --set ComputerName  "SkippersMBP"
    sudo scutil --set HostName      "SkippersMBP"
    sudo scutil --set LocalHostName "SkippersMBP"
    dscacheutil -flushcache
    sudo dw /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

    # GENERAL UI/UX
    dw NSGlobalDomain AppleInterfaceStyle -string "Dark"               # dark mode
    dw NSGlobalDomain AppleFontSmoothing -int 0                        # subpixel font smoothing (0-3)
    dw NSGlobalDomain AppleShowScrollBars -string "Always"             # scollbar (`WhenScrolling`, `Automatic` and `Always`)
    dw NSGlobalDomain InitialKeyRepeat -int 15                         # key repeat delay
    dw NSGlobalDomain KeyRepeat -int 1                                 # key repeat speed
    dw NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false     # disable automatic capitalization
    dw NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false   # disable smart dashes
    dw NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false # disable preriod auto-substitution
    dw NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false  # disable smart quotes
    dw NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false # disable autocorrect
    dw com.apple.desktopservices DSDontWriteNetworkStores -bool true   # no .DS_Store on network
    dw com.apple.desktopservices DSDontWriteUSBStores -bool true       # no .DS_Store on usb volumes

    # DOCK
    dw com.apple.dock autohide -bool true                # autohide/show dock
    dw com.apple.dock autohide-delay -float 0            # dock hide delay
    dw com.apple.dock autohide-time-modifier -float 0    # no hide animation
    dw com.apple.dock launchanim -bool false             # app open animation
    dw com.apple.dock mineffect -string "scale"          # min(max)imize effect
    dw com.apple.dock minimize-to-application -bool true # minimize to app icon
    dw com.apple.dock mouse-over-hilite-stack -bool true # Enable highlight hover effect for the grid view of a stack
    dw com.apple.dock orientation -string "bottom"       # dock position (left, bottom, right)
    dw com.apple.dock ResetLaunchPad -bool true          # reset launchpad layout
    dw com.apple.dock show-recents -bool false           # dont show recent apps
    dw com.apple.dock tilesize -int 36                   # dock item size in pixels
    dw com.apple.dock workspaces-auto-swoosh -boolean NO # when opening app, switch to space with open window
    dockutil --no-restart --remove all                   # clear dock elements
    killall Dock

    # FINDER
    dw com.apple.finder AppleShowAllFiles -bool true # show hidden files
    dw com.apple.finder DisableAllAnimations -bool true # disable window animations
    dw com.apple.finder QuitMenuItem -bool false # allow quitting via ⌘ + Q; doing so will also hide desktop icons
    killall Finder

    # SCREENSHOTS
    dw com.apple.screencapture disable-shadow -bool true # disable shadow in screenshots
    dw com.apple.screencapture location -string "${HOME}/Documents" # screenshot folder
    dw com.apple.screencapture type -string "png" # screenshot fmt (BMP, GIF, JPG, PDF, TIFF)
}

tap() { brew tap --quiet }
brw() { yes | brew install --quiet $@ }
packages() {
    # tap "cmacrae/formulae" && brw "cmacrae/formulae/spacebar" --HEAD # status bar for osx
    tap "FelixKratz/formulae" && brw "sketchybar"
    tap "homebrew/cask-fonts"                  \
        && brw "font-dejavusansmono-nerd-font" \
        && brw "font-fira-code-nerd-font"      \
        && brw "font-hack-nerd-font"           \
        && brw "font-robotomono-nerd-font"     \
        && brw "font-saucecodepro-nerd-font"   \
        && brw "font-ubuntumono-nerd-font"
    tap "koekeishiya/formulae"                     \
        && brw "koekeishiya/formulae/skhd"  && skhd  --start-service \
        && brw "koekeishiya/formulae/yabai" \
            && sudo echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | awk '{print $1}') $(which yabai) --load-sa" \
                | sudo tee /private/etc/sudoers.d/yabai \
            && yabai --start-service
    tap "zegervdv/zathura"                \
        && brw "zegervdv/zathura/zathura" \
        && brw "zegervdv/zathura/girara"  \
        && brw "zegervdv/zathura/zathura-pdf-poppler" \
        && mkdir -p $(brew --prefix zathura)/lib/zathura \
        && ln -sf $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib \
            $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
    brw "asciiquarium"                                      # showing off
    brw "autojump"                                          # python formatter
    brw "balenaetcher"                                        #
    # TODO: double-check you may need to do brew install --cask basictex to ensure the installer is run
    brw "basictex" && texlive_configure                     # latex bundle (alternative full package: mactex)
        # brw perl && cpan -i Tk # CPAN = comprehensive perl archive network
    brw "bat"                                               # cat alternative with syntax highlight (for file manager)
    brw "bc"                                                # terminal calculator
    brw "calc"                                              # terminal calculator
    brw "calcurse"                                          #
    brw "ccat"                                              # cat alternative with syntax highlight (for file manager)
    brw "chafa"                                             # terminal graphics
    brw "clang-format"                                      #
    brw "cliclick"                                          # emulate mouse motion
    brw "coreutils"                                         #
    brw "dmenu"
    brw "docker" "docker-credential-helper" "docker-machine"
    brw "dockutil"                                          # tool for configuring osx dock
    brw "enscript"                                          # for converting code to postscript
    brw "figlet" && ghb "xero/figlet-fonts.git"                # for writing ascii text
    brw "fzf" && yes | $(brew --prefix)/opt/fzf/install --xdg # configure xdg shell completion
    brw "gcc"                                               #
    brw "geckodriver"                                       #
    brw "ghostscript"                                       # for ps2pdf
    brw "glow"                                              # terminal markdown highlighting
    brw "gnu-getopt"                                        #
    brw "gnu-typist"                                        #
    brw "gnuplot"                                           # graph plotting
    brw "go"                                                # golang
    brw "gotop"                                             #
    brw "gpg"                                               #
    brw "gptfdisk"                                          # crucial for quickly fixing apfs partition hexcode
    brw "highlight"                                         # cat alternative with syntax highlight (for file manager)
    brw "htop"                                              #
    brw "imagemagick"                                       #
    brw "jq"                                                #
    brw "jupyterlab"                                        #
    brw "lf"                                                #
    brw "libusb"                                            #
    brw "llvm"                                              #
    brw "lolcat"                                            # make printed output colorful
    brw "media-info"                                        # display data for audio/video (for file manager)
    brw "mpv"                                               # for playing videos
    brw "ncdu"
    brw "neofetch"                                          #
    brw "neovim" --HEAD && pin "pynvim"                     # python support for neovim
    brw "newsboat"                                          # terminal RSS feed
    brw "openssl"                                           # required for generating crypt(3) passwords
    brw "pandoc"                                            #
    brw "pass"                                              # password store
    brw "pfetch"                                            # lightweight system info tool
    brw "pidof"                                             # used by pywal
    brw "pipes-sh"                                          #
    brw "platformio"                                        # massive embedded development suite
    brw "poppler"                                           # for pdftotext and pdftoppm
    brw "python"                                            #
    brw "redshift"                                          #
    brw "ripgrep"                                           # searcher used with vim
    brw "rsync"                                             #
    brw "sc-im" --HEAD
    brw "screenfetch"                                       # another system info tool, probably the slowest
    brw "the_silver_searcher"                               # searcher used with vim
    brw "tmux"                                              #
    brw "trash-cli"                                         # send items to trash from temrinal
    brw "tty-clock"                                         #
    brw "unar"                                              #
    brw "verilator"                                         #
    brw "wget"                                              #
    brw "youtube-dl"                                        #
    brw "zsh-autosuggestions"                               #
    brw "zsh-syntax-highlighting"                           #
    brw "xorriso"                                           # for making custom ubuntu preseed
    brw "alacritty" \
        && pin "alacritty-colorscheme" \
        && ghb "aaron-williamson/base16-alacritty.git" \
        && ghb "egeesin/alacritty-color-export.git" \
        && ghb "eendroroy/alacritty-theme.git" # terminal
    brw "coolterm"                                          # serial port gui for arduino, see https://docs.platformio.org/en/latest/faq.html?highlight=coolterm#advanced-serial-monitor-with-ui
    brw "discord"                                           #
    brw "dmenu-mac"                                         #
    brw "firefox" && /Applications/Firefox.app/Contents/MacOS/firefox -setDefaultBrowser -silent
    brw "fliqlo"                                            # screensaver
    brw "ftdi-vcp-driver"             # arduino driver
    brw "inkscape"                                          # for latex drawings
    brw "librepcb"                                          # electrical schematic drawing tool
    brw "minecraft" && ln -sf "$HOME/.config/minecraft/options.txt" "$HOME/Library/ApplicationSupport/Minecraft/options.txt"
    brw "spotify" && ln -sf "$HOME/.local/share/spotify/prefs" "$HOME/Library/ApplicationSupport/Spotify/prefs"
    brw "xctu"                                              #
    brw "xquartz"                                           # for rendering ssh windows
    brw "thunderbird"
    brw "zoom"                                            #
    ghb "dexpota/kitty-themes.git"              #
    ghb "kdrag0n/base16-kitty.git"              #
    ghb "stark/Color-Scripts.git"               #
    pin "autopep8"                              # python style formatter
    pin "flake8"                                # python linter
    pin "pip"                                   # installs pip
    pin "pycodestyle"                           # python style linter, requred by autopep8
    pin "pylint"                                # python linter
}

bootstrap() {
    bigprint "Prepping For Bootstrap" && prep && echo "OS Prep Complete."
    bigprint "Syncing dotfiles repo to home" && dotfiles
    bigprint "Installing Packages" && packages
    bigprint "Runnung Miscellaneous Post-Package Installs and Configs" && config && echo "OS Config Complete. Restart Required"
}

matlab_install() {
    # MATLAB INSTALLATION (EXPERIMENTAL)
    bigprint "Installing MATLAB"

    local version="R2019b"
    local DMGPATH="$XDG_DATA_HOME/matlab/matlab_${version}_maci64.dmg"
    local INSTPATH="/Volumes/matlab_${version}_maci64/InstallForMacOSX.app"

    function dmg_cleanup() {
    # remove dmg and installer on exit, failure, etc.
    local installer=$(basename $1); local mountname=$(dirname $1)
    pgrep "${installer%.*}"       && killall "${installer%.*}"
    [ -d  "/Volumes/$mountname" ] && diskutil unmount force "/Volumes/$mountname"
    rm -f "$2"
    }
    trap "dmg_cleanup $INSTPATH" "$DMGPATH" INT ERR TERM EXIT

    # unzip, mount, and run installer, waiting for installer to close
    unzip -d $(dirname $DMGPATH) "$DMGPATH.zip"
    hdiutil attach "$DMGPATH" -nobrowse
    open -W "/Volumes/matlab_${version}_maci64/InstallForMacOSX.app"

    # symlink tools
    sudo ln -sf /Applications/MATLAB_${version}.app/bin/matlab       /usr/local/bin/matlab
    sudo ln -sf /Applications/MATLAB_${version}.app/bin/maci64/mlint /usr/local/bin/mlint

    # undo traps
    trap - INT ERR TERM EXIT
    echo "MATLAB Install Complete."
}
