#!/bin/zsh

#===================================================================
# Dock and Dashboard Config (Requires brew dockutil)
#===================================================================

cd "$(dirname $0)"

# Close any open System Preferences panes
osascript -e 'quit app "System Preferences"'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Enable highlight hover effect for the grid view of a stack (Dock)
defaults write com.apple.dock mouse-over-hilite-stack -bool true

# Set the icon size of Dock items to 36 pixels
defaults write com.apple.dock tilesize -int 36

# move dock orientation (options are left, bottom, right)
defaults write com.apple.dock orientation -string "bottom"

# Change minimize/maximize window effect
defaults write com.apple.dock mineffect -string "scale"

# Minimize windows into their application’s icon
defaults write com.apple.dock minimize-to-application -bool false

# Automatically hide and show the Dock
defaults write com.apple.dock autohide -bool false

# Don’t show recent applications in Dock
defaults write com.apple.dock show-recents -bool false

# Reset Launchpad, but keep the desktop wallpaper intact
# find "${HOME}/Library/Application Support/Dock" -name "*-*.db" -maxdepth 1 -delete; killall Dock
defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock

# Add iOS & Watch Simulator to Launchpad
# sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app" "/Applications/Simulator.app"
# sudo ln -sf "/Applications/Xcode.app/Contents/Developer/Applications/Simulator (Watch).app" "/Applications/Simulator (Watch).app"

# set dock apps
dockutil --no-restart --remove all
dockutil --no-restart --add "/System/Applications/Launchpad.app"
dockutil --no-restart --add "/System/Applications/System Preferences.app"
dockutil --no-restart --add "/Applications/Bitwarden.app"
dockutil --no-restart --add "/Applications/TickTick.app"
dockutil --no-restart --add "/System/Applications/Notes.app"
dockutil --no-restart --add "/System/Applications/Mail.app"
dockutil --no-restart --add "/System/Applications/Messages.app"
dockutil --no-restart --add "/Applications/Firefox.app"
dockutil --no-restart --add "/Applications/Safari.app"
dockutil --no-restart --add "/Applications/MATLAB_R2019b.app"
dockutil --no-restart --add "/Applications/Mathematica.app"
dockutil --no-restart --add "/Applications/Visual Studio Code.app"
dockutil --no-restart --add "/Applications/Sublime Text.app"
dockutil --no-restart --add "/Applications/Sublime Merge.app"
dockutil --no-restart --add "/System/Applications/Utilities/Terminal.app"
dockutil --no-restart --add "/Applications/iTerm.app"
dockutil --no-restart --add "/Applications/XCTU.app"
dockutil --no-restart --add "/Applications/Spotify.app"
dockutil --no-restart --add "/Applications/Minecraft.app"

dockutil --no-restart --add "~/Downloads" --view fan --display stack --sort dateadded

# reset dock
killall Dock
echo "Dock Config Done. Note that some of these changes require a logout/restart to take effect."
