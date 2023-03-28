source library.sh

function prep(){
    sudo softwareupdate -irR && xcode-select --install
    which brew &>/dev/null || (sudo curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash)
}

function matlab_install() {
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

function config() {
  # disable time machine and allow apps downloaded from anywhere
  sudo tmutil disable; sudo spctl --master-disable

  # Set computer name
  sudo scutil --set ComputerName  "SkippersMBP"
  sudo scutil --set HostName      "SkippersMBP"
  sudo scutil --set LocalHostName "SkippersMBP"
  dscacheutil -flushcache
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

  # configure osx ui/ux
  $HOME/.config/aqua/defaults

  # configure xdg shell completion
  $(brew --prefix)/opt/fzf/install --xdg
}

function bootstrap() {
  bigprint "Prepping For Bootstrap" && prep && echo "OS Prep Complete."
  bigprint "Syncing dotfiles repo to home" && dotfiles
  bigprint "Installing Packages" && packages
  bigprint "Runnung Miscellaneous Post-Package Installs and Configs" && config && echo "OS Config Complete. Restart Required"
}

function packages {
  brf "Packages/brewfile" \
    && ( [ yabai --check-sa ] || sudo yabai --install-sa ) \
    && /Applications/Firefox.app/Contents/MacOS/firefox -setDefaultBrowser -silent \
    && mkdir -p $(brew --prefix zathura)/lib/zathura && ln -sf $(brew --prefix zathura-pdf-poppler)/libpdf-poppler.dylib $(brew --prefix zathura)/lib/zathura/libpdf-poppler.dylib \
    && ln -sf "$HOME/.config/minecraft/options.txt" "$HOME/Library/ApplicationSupport/Minecraft/options.txt" \
    && ln -sf "$HOME/.local/share/spotify/prefs"    "$HOME/Library/ApplicationSupport/Spotify/prefs" # homebrew installs

  git "https://github.com/aaron-williamson/base16-alacritty.git" #
  git "https://github.com/eendroroy/alacritty-theme.git"         #
  git "https://github.com/dexpota/kitty-themes.git"              #
  git "https://github.com/kdrag0n/base16-kitty.git"              #
  git "https://github.com/egeesin/alacritty-color-export.git"    #
  git "https://github.com/xero/figlet-fonts.git"                 #
  git "https://github.com/stark/Color-Scripts.git"               #

  pip "alacritty-colorscheme"                                    # alacritty color changer
  pip "autopep8"                                                 # python style formatter
  pip "flake8"                                                   # python linter
  pip "pip"                                                      # installs pip
  pip "pycodestyle"                                              # python style linter, requred by autopep8
  pip "pylint"                                                   # python linter
  pip "pynvim"                                                   # python support for neovim
}
