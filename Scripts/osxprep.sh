#!/bin/zsh

#===============================================================================
# OSX/COMMANDLINETOOLS UPDATE
#===============================================================================

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# ensure zsh is the default shell
echo "Changing User Shell to ZSH"
sudo chsh -s /bin/zsh

# Update OS
echo "Updating OSX"
sudo softwareupdate -i -a -R --verbose # use sudo -s if you want -R option

# allows apps downloaded from anywhere
sudo spctl --master-disable

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "SkippersMBP"
sudo scutil --set HostName "SkippersMBP"
sudo scutil --set LocalHostName "SkippersMBP"
dscacheutil -flushcache
sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

# Turn Dark mode on
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# Set a custom wallpaper image
WALLPAPER="$XDG_DATA_HOME/wallpapers/beams.jpeg"
osascript -e "tell application \"Finder\" to set desktop picture to \"$(realpath "$WALLPAPER")\" as POSIX file"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$(realpath "$WALLPAPER")\""

# alternative that requires disabled SIP
# Set a custom wallpaper image. `DefaultDesktop.jpg` is already a symlink, and
# all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
#rm -rf ~/Library/Application Support/Dock/desktoppicture.db
#sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
#sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg

# Disable local Time Machine snapshots
sudo tmutil disablelocal

# fix wget history
mkdir -p "$XDG_CACHE_HOME/wget-hsts"
rm -rf "$HOME/.wget-hsts"

# fix zsh_history
rm -rf "$HOME/.zsh_history"

# install command line tools
xcode-select -p &>/dev/null 2>&1 || (
  echo "Installing Command Line Tools..." &&
  xcode-select --install
)
