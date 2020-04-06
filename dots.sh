#!/bin/zsh

DIR=$(dirname $0)

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
      source "$DIR/bootstrap.sh" -f
    fi
    if [[ $ARG == "osxprep" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Updating OSX and installing Xcode command line tools"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/osxprep.sh"
    fi
    if [[ $ARG == "packages" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Installing Packages (Homebrew, Cask, Mas, Npm, Pip, etc."
      echo "This might take a while to complete."
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Install/Packages/packages.sh"
    fi

    # if [[ $ARG == "mathematica" ]] || [[ $ARG == "all" ]]; then
    #   echo ""
    #   echo "------------------------------"
    #   echo "Installing Mathematica"
    #   echo "------------------------------"
    #   echo ""
    #   "./Math/Mathematica/mathematica.sh"
    # fi
    # if [[ $ARG == "matlab" ]] || [[ $ARG == "all" ]]; then
    #   echo ""
    #   echo "------------------------------"
    #   echo "Installing Matlab"
    #   echo "------------------------------"
    #   echo ""
    #   "./Math/Matlab/matlab.sh" # ttab
    # fi
    if [[ $ARG == "dmenu" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Kitty Theme"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Install/dmenu"
    fi
    if [[ $ARG == "kitty" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Kitty Theme"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Install/kitty_themes"
    fi
    if [[ $ARG == "refind" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up rEFInd"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Install/refind"
    fi
    if [[ $ARG == "termpdf" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Installing Termpdf"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Install/termpdf"
    fi
    if [[ $ARG == "yabai" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Yabai"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Install/yabai_sa"
    fi
    if [[ $ARG == "dock" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring Dock"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Config/dock"
    fi
    if [[ $ARG == "docker" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Sign In To Docker Account"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Config/dockerlogin"
    fi
    if [[ $ARG == "osx" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring OSX UI"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/Config/osx"
    fi
    if [[ $ARG == "minecraft" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Minecraft"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/XDG/minecraft"
    fi
    if [[ $ARG == "slack" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Slack"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/XDG/slack"
    fi
    if [[ $ARG == "spotify" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Spotify"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/XDG/spotify"
    fi
    if [[ $ARG == "sublime" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Setting Up Sublime"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/XDG/sublime"
    fi
    if [[ $ARG == "vscode" ]] || [[ $ARG == "all" ]]; then
      echo ""
      echo "------------------------------"
      echo "Configuring VS Code"
      echo "------------------------------"
      echo ""
      source "$DIR/Scripts/XDG/vscode"
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
