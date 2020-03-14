#!/bin/zsh

function runDots() {
  # Ask for the administrator password upfront
  sudo -v

  # Keep-alive: update existing `sudo` time stamp until the script has finished
  while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

  # Run sections based on command line arguments
  for ARG in "$@"
  do
    if [[ $ARG == "bootstrap" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Syncing the dotfiles repo to home "
      echo "------------------------------"
      echo ""
      source "bootstrap.sh" -f
      cd ~/.dotfiles
    fi
    if [[ $ARG == "osxprep" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Updating OSX and installing Xcode command line tools"
      echo "------------------------------"
      echo ""
      "./OSX/osxprep.sh"
    fi
    # if [[ $ARG == "brew" ]] || [[ $ARG == "all" ]]; then
    #   echo ""
    #   echo "------------------------------"
    #   echo "Installing Homebrew, Cask, and Mas Packages."
    #   echo "This might take a while to complete, as some formulae need to be installed from source."
    #   echo "------------------------------"
    #   echo ""
    #   "./Brew/brew.sh"
    # fi
    if [[ $ARG == "backups" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Pulling Private Backup Storage"
      echo "------------------------------"
      echo ""
      "./backups.sh"
    fi
    if [[ $ARG == "packages" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Installing Packages (Homebrew, Cask, Mas, Npm, Pip, etc."
      echo "This might take a while to complete."
      echo "------------------------------"
      echo ""
      "./Packages/packages.sh"
    fi
    if [[ $ARG == "osx" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring OSX UI"
      echo "------------------------------"
      echo ""
      "./OSX/osx.sh"
    fi
    if [[ $ARG == "dock" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring Dock"
      echo "------------------------------"
      echo ""
      "./OSX/dock.sh"
    fi
    # if [[ $ARG == "pip" ]] || [[ $ARG == "all" ]]; then
    #   echo ""
    #   echo "------------------------------"
    #   echo "Setting up Python Global pip Packages"
    #   echo "------------------------------"
    #   echo ""
    #   "./Pip/pip.sh"
    # fi
    # if [[ $ARG == "npm" ]] || [[ $ARG == "all" ]]; then
    #   echo ""
    #   echo "------------------------------"
    #   echo "Setting up Global npm Packages"
    #   echo "------------------------------"
    #   echo ""
    #   "./Npm/npm.sh"
    # fi
    if [[ $ARG == "sublime" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Sublime"
      echo "------------------------------"
      echo ""
      "./sublime.sh"
    fi
    if [[ $ARG == "vscode" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring VS Code"
      echo "------------------------------"
      echo ""
      "./vscode.sh"
    fi
    if [[ $ARG == "firefox" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Firefox"
      echo "------------------------------"
      echo ""
      "./firefox.sh"
    fi
    if [[ $ARG == "safari" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring Safari"
      echo "------------------------------"
      echo ""
      "./OSX/safari.sh"
    fi
    if [[ $ARG == "minecraft" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Minecraft"
      echo "------------------------------"
      echo ""
      "./minecraft.sh"
    fi
    if [[ $ARG == "openemu" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up OpenEmu"
      echo "------------------------------"
      echo ""
      "./openemu.sh"
    fi
    if [[ $ARG == "slack" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Slack"
      echo "------------------------------"
      echo ""
      "./slack.sh"
    fi
    if [[ $ARG == "spotify" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Spotify"
      echo "------------------------------"
      echo ""
      "./spotify.sh"
    fi
    if [[ $ARG == "docker" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Sign In To Docker Account"
      echo "------------------------------"
      echo ""
      "./dockerlogin.sh"
    fi
    if [[ $ARG == "github" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Sign In To Github Account"
      echo "------------------------------"
      echo ""
      "./gitlogin.sh"
    fi
    if [[ $ARG == "mathematica" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Installing Mathematica"
      echo "------------------------------"
      echo ""
      "./Mathematica/mathematica.sh"
    fi
    if [[ $ARG == "matlab" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Installing Matlab"
      echo "------------------------------"
      echo ""
      "./Matlab/matlab.sh" # ttab
    fi
    if [[ $ARG == "alacritty" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring Alacritty"
      echo "------------------------------"
      echo ""
      "./Alacritty/alacritty.sh" # ttab
    fi
    if [[ $ARG == "kitty" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Kitty"
      echo "------------------------------"
      echo ""
      "./Kitty/kitty.sh"
    fi
    if [[ $ARG == "ranger" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring Ranger"
      echo "------------------------------"
      echo ""
      "./Ranger/ranger.sh" # ttab
    fi
    if [[ $ARG == "refind" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up rEFInd"
      echo "------------------------------"
      echo ""
      "./rEFInd/refind.sh" # ttab
    fi
    if [[ $ARG == "skhd" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Skhd"
      echo "------------------------------"
      echo ""
      "./Skhd/skhd.sh" # ttab
    fi
    if [[ $ARG == "yabai" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Yabai"
      echo "------------------------------"
      echo ""
      "./Yabai/yabai.sh" # ttab
    fi
    if [[ $ARG == "zathura" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring Zathura"
      echo "------------------------------"
      echo ""
      "./Zathura/zathura.sh" # ttab
    fi
    if [[ $ARG == "termpdf" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Installing Termpdf"
      echo "------------------------------"
      echo ""
      "./termpdf.sh" # ttab
    fi
  done

  echo "------------------------------"
  echo "Completed running .dots, restart your computer to ensure all updates take effect"
  echo "------------------------------"
}

# read -p "This may overwrite existing files in your home directory. Are you sure? (y/n) " -n 1;
# echo "";
printf '%s ' "This may overwrite existing files in your home directory. Are you sure? (y/n)";
read REPLY;

if [[ $REPLY =~ ^[Yy]$ ]]; then
    runDots "$@"
fi;

unset runDots;
