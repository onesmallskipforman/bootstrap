source library.sh

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

prep(){
    sudo softwareupdate -irR && xcode-select --install
    URL="https://raw.githubusercontent.com/Homebrew/install/master/install.sh"
    which brew  &>/dev/null || (sudo curl -fsSL $URL | NONINTERACTIVE=1 /bin/bash -c )
    sudo spctl --master-disable # allow apps downloaded from anywhere
}

config() {
    dw() { defaults write $@ }
    sdw() { sudo defaults write $@ }
    local g='NSGlobalDomain'; local d='com.apple.dock'
    local ds='com.apple.desktopservices'; local s='com.apple.screencapture'

    # disable time machine
    sudo tmutil disable

    # Set computer name
    sudo scutil --set ComputerName  "SkippersMBP"
    sudo scutil --set HostName      "SkippersMBP"
    sudo scutil --set LocalHostName "SkippersMBP"
    dscacheutil -flushcache
    sdw /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

    # GENERAL UI/UX
    dw $g AppleInterfaceStyle -string "Dark"               # dark mode
    dw $g AppleFontSmoothing -int 0                        # subpixel font smoothing (0-3)
    dw $g AppleShowScrollBars -string "Always"             # scollbar (`WhenScrolling`, `Automatic` and `Always`)
    dw $g InitialKeyRepeat -int 15                         # key repeat delay
    dw $g KeyRepeat -int 1                                 # key repeat speed
    dw $g NSAutomaticCapitalizationEnabled -bool false     # disable automatic capitalization
    dw $g NSAutomaticDashSubstitutionEnabled -bool false   # disable smart dashes
    dw $g NSAutomaticPeriodSubstitutionEnabled -bool false # disable preriod auto-substitution
    dw $g NSAutomaticQuoteSubstitutionEnabled -bool false  # disable smart quotes
    dw $g NSAutomaticSpellingCorrectionEnabled -bool false # disable autocorrect
    dw $ds DSDontWriteNetworkStores -bool true   # no .DS_Store on network
    dw $ds DSDontWriteUSBStores -bool true       # no .DS_Store on usb volumes

    # DOCK
    dw $d autohide -bool true                # autohide/show dock
    dw $d autohide-delay -float 0            # dock hide delay
    dw $d autohide-time-modifier -float 0    # no hide animation
    dw $d launchanim -bool false             # app open animation
    dw $d mineffect -string "scale"          # min(max)imize effect
    dw $d minimize-to-application -bool true # minimize to app icon
    dw $d mouse-over-hilite-stack -bool true # Enable highlight hover effect for the grid view of a stack
    dw $d orientation -string "bottom"       # dock position (left, bottom, right)
    dw $d ResetLaunchPad -bool true          # reset launchpad layout
    dw $d show-recents -bool false           # dont show recent apps
    dw $d tilesize -int 36                   # dock item size in pixels
    dw $d workspaces-auto-swoosh -boolean NO # click app wil switch to space with open window
    dw $d persistent-apps -array # clear dock elements
    killall Dock

    # FINDER
    dw $f AppleShowAllFiles -bool true # show hidden files
    dw $f DisableAllAnimations -bool true # disable window animations
    dw $f QuitMenuItem -bool false # allow quitting via ⌘ + Q; doing so will also hide desktop icons
    killall Finder

    # SCREENSHOTS
    dw $sc disable-shadow -bool true # disable shadow in screenshots
    dw $sc location -string "${HOME}/Documents" # screenshot folder
    dw $sc type -string "png" # screenshot fmt (BMP, GIF, JPG, PDF, TIFF)
    unset -f dw; unset -f sdw
}

yabai_sudoers() {
    sudo echo "$(whoami) ALL=(root) NOPASSWD:
        sha256:$(shasum -a 256 $(which yabai) | awk '{print $1}')
        $(which yabai) --load-sa" \
        | sed -r 's/[[:space:]]+/ /g' | tr -d '\n' \
        | sudo tee /private/etc/sudoers.d/yabai
}

zathura_configure() {
    mkdir -p $(brew --prefix zathura)/lib/zathura \
    ln -sf $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib \
           $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib
}

packages() {
    brw "python3" && pin "pip" # pip installs pip

    brw "alacritty" \
        && ghb "aaron-williamson/base16-alacritty" \
        && ghb "alacritty/alacritty-theme"
    # mkdir -p ~/.config/alacritty/themes
    # git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
    brw "asciiquarium" "pipes-sh" "tty-clock" # showing off
    brw "autojump" # python formatter
    brw "balenaetcher"
    {
        brw "basictex" && texlive_configure # latex (full package: mactex) # TODO: double-check you may need brew install --cask to run installer
        brw "inkscape" # for latex drawings
    }
    brw "bat" "ccat" "highlight" # cat variant with highlight (for file mgr)
    brw "bc" "calc" # terminal calculators
    brw "calcurse"
    brw "chafa" # terminal graphics
    brw "clang-format"
    brw "cmacrae/formulae/spacebar" --HEAD # status bar for osx
    brw "coolterm" # serial port gui for arduino and platformio
    brw "coreutils"
    brw "discord"
    brw "dmenu"
    brw "docker" "docker-credential-helper" "docker-compose" "colima"
    brw "enscript" # for converting code to postscript
    brw "FelixKratz/formulae/sketchybar"
    brw "figlet" && ghb "xero/figlet-fonts.git" # for writing ascii text
    brw "font-dejavusansmono-nerd-font"
    brw "font-fira-code-nerd-font"
    brw "font-hack-nerd-font"
    brw "font-robotomono-nerd-font"
    brw "font-saucecodepro-nerd-font"
    brw "font-ubuntumono-nerd-font"
    brw "fzf" && $(brew --prefix)/opt/fzf/install --all --xdg --completion
    #TODO: replace with 'ghb "junegunn/fzf" && ~/.local/src/fzf/install --all --xdg --completion'
    brw "gcc"
    brw "geckodriver"
    brw "ghostscript" # for ps2pdf with enscript
    brw "glow" # terminal markdown highlighting
    brw "gnu-getopt"
    brw "gnu-typist"
    brw "gnuplot" # graph plotting
    brw "go"
    brw "gotop"
    brw "gpg"
    brw "gptfdisk" # crucial for quickly fixing apfs partition hexcode
    brw "htop"
    brw "imagemagick"
    brw "jq"
    brw "jupyterlab"
    brw "koekeishiya/formulae/skhd"  && skhd  --start-service && brw "cliclick"
    brw "koekeishiya/formulae/yabai" && yabai_sudoers && yabai --start-service
    brw "lazygit"
    brw "lf"
    brw "libusb"
    brw "llvm"
    brw "lolcat" # make printed output colorful
    brw "media-info" # display data for audio/video (for file manager)
    brw "mpv" # for playing videos
    brw "ncdu"
    brw "neofetch" "fastfetch" "pfetch" # system info tools
    brw "neovim" && pin "pynvim"
    brw "newsboat" # terminal RSS feed
    brw "openssl" # required for generating crypt(3) passwords
    brw "pandoc"
    brw "pass" # password store
    brw "pfetch" # lightweight system info tool
    brw "platformio" # massive embedded development suite
    brw "poppler" # for pdftotext and pdftoppm
    brw "redshift"
    brw "ripgrep" # searcher
    brw "rsync"
    brw "sc-im" --HEAD
    brw "tmux"
    brw "trash-cli" # send items to trash from temrinal
    brw "unar"
    brw "verilator"
    brw "wget"
    brw "xorriso" # for making custom ubuntu preseed
    brw "youtube-dl"
    brw "zsh-autosuggestions" "zsh-syntax-highlighting"
    brw "dmenu-mac"
    brw "firefox" && firefox -setDefaultBrowser -silent
    brw "fliqlo" # screensaver
    brw "ftdi-vcp-driver" # arduino driver
    brw "librepcb" # electrical schematic drawing tool
    brw "minecraft" && ln -sf "$HOME/.config/minecraft/options.txt" "$HOME/Library/ApplicationSupport/Minecraft/options.txt"
    brw "spotify" && ln -sf "$HOME/.local/share/spotify/prefs" "$HOME/Library/ApplicationSupport/Spotify/prefs"
    brw "xctu"
    brw "xquartz" # for x11 forwading
    brw "thunderbird"
    brw "zoom"
    brw "zegervdv/zathura/zathura" --HEAD "zegervdv/zathura/girara" --HEAD "zegervdv/zathura/zathura-pdf-poppler" && zathura_configure
    ghb "stark/Color-Scripts"
    pin "https://github.com/dylanaraps/pywal/archive/master.zip" && brw "pidof"

    brew upgrade --greedy
    sudo chown -R $(whoami) $(brew --prefix)/* && brew cleanup --prune=all
    python3 -m pip cache purge
}

bootstrap() {
    supersist
    bigprint "Prepping For Bootstrap"  ; prep
    bigprint "Copying dotfiles to home"; syncDots
    bigprint "Configure OS"            ; config
    bigprint "Installing Packages"     ; packages
    bigprint "OS Config Complete. Restart Required"
}
