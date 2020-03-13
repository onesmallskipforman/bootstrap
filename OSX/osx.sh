#!/bin/zsh

#===============================================================================
# General UI/UX
#===============================================================================

cd "$(dirname $0)"

# Close any open System Preferences panes
osascript -e 'quit app "System Preferences"'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Turn Dark mode on
# defaults write "Apple Global Domain" "AppleInterfaceStyle" "dark"
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# Set computer name (as done via System Preferences → Sharing)
sudo scutil --set ComputerName "SkippersMBP"
sudo scutil --set HostName "SkippersMBP"
sudo scutil --set LocalHostName "SkippersMBP"
sudo defaults read /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "SkippersMBP"

# allows apps downloaded from anywhere
sudo spctl --master-disable

# Always show scrollbars (Possible values: `WhenScrolling`, `Automatic` and `Always`)
defaults write NSGlobalDomain AppleShowScrollBars -string "Always"

# Disable Resume system-wide
defaults write com.apple.systempreferences NSQuitAlwaysKeepsWindows -bool false

# Disable automatic capitalization as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution as it’s annoying when typing code
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes as they’re annoying when typing code
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable the “Are you sure you want to open this application?” dialog
#defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable auto-correct
# defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

# Set a custom wallpaper image
WALLPAPER="Wallpapers/beams.jpeg"
osascript -e "tell application \"Finder\" to set desktop picture to \"$(realpath "$WALLPAPER")\" as POSIX file"
osascript -e "tell application \"System Events\" to tell every desktop to set picture to \"$(realpath "$WALLPAPER")\""

# alternative that requires disabled SIP
# Set a custom wallpaper image. `DefaultDesktop.jpg` is already a symlink, and
# all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
#rm -rf ~/Library/Application Support/Dock/desktoppicture.db
#sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
#sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg

#===============================================================================
# Finder
#===============================================================================

# Finder: allow quitting via ⌘ + Q; doing so will also hide desktop icons
defaults write com.apple.finder QuitMenuItem -bool true

# Finder: disable window animations and Get Info animations
defaults write com.apple.finder DisableAllAnimations -bool true

# Finder: show hidden files by default
defaults write com.apple.finder AppleShowAllFiles -bool true

#===============================================================================
# Trackpad, mouse, keyboard, Bluetooth accessories, and input
#===============================================================================

defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15
# defaults write -g KeyRepeat -int 1

#===============================================================================
# Kill affected applications
#===============================================================================

for app in "Activity Monitor" \
	"Address Book" \
	"Calendar" \
	"cfprefsd" \
	"Contacts" \
	"Finder" \
	"Mail" \
	"Messages" \
	"Photos" \
	"SystemUIServer" \
	"iCal"; do
	killall "${app}" &> /dev/null
done

# "Safari" \
# "Terminal" \

echo "OSX Config Done. Note that some of these changes require a logout/restart to take effect."
