#!/bin/zsh

#===================================================================
# Terminal Config
#===================================================================

cd "$(dirname $0)"

# Close any open System Preferences panes
osascript -e 'quit app "System Preferences"'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until `.macos` has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# terminal pref plist
# PLIST="$HOME/Library/Preferences/com.apple.Terminal.plist"

#set window width to 120
# sudo /usr/libexec/PlistBuddy -c "Add :Window\ Settings:Homebrew:columnCount integer 120" $PLIST
# defaults write $PLIST "NSWindow Frame TTWindow Homebrew" "97 302 1075 366 0 0 1280 777 "

# install saved homebrew theme
osascript <<EOD
tell application "Terminal"

    local allOpenedWindows
    local initialOpenedWindows
    local windowID
    set themeName to "Homebrew"

    (* Store the IDs of all the open terminal windows. *)
    set initialOpenedWindows to id of every window

    (* Open the custom theme so that it gets added to the list
       of available terminal themes (note: this will open two
       additional terminal windows). *)
    do shell script "open '$PWD/" & themeName & ".terminal'"

    (* Wait a little bit to ensure that the custom theme is added. *)
    delay 1

    (* Set the custom theme as the default terminal theme. *)
    set default settings to settings set themeName

    (* Get the IDs of all the currently opened terminal windows. *)
    set allOpenedWindows to id of every window

    repeat with windowID in allOpenedWindows

        (* Close the additional windows that were opened in order
           to add the custom theme to the list of terminal themes. *)
        if initialOpenedWindows does not contain windowID then
            close (every window whose id is windowID)

        (* Change the theme for the initial opened terminal windows
           to remove the need to close them in order for the custom
           theme to be applied. *)
        else
            set current settings of tabs of (every window whose id is windowID) to settings set themeName
        end if

    end repeat

end tell
EOD
# change terminal theme to Homebrew (requires logout and log back in)
# defaults write com.apple.terminal "Default Window Settings" -string Homebrew
# defaults write com.apple.terminal "Startup Window Settings" -string Homebrew


# Ensure Homebrew Theme is the Default
defaults write com.apple.terminal "Default Window Settings" -string Homebrew
defaults write com.apple.terminal "Startup Window Settings" -string Homebrew

# disable focus follows mouse for Terminal/X11 apps (both lines needed for true)
# i.e. hover over a window and start typing in it without clicking first
defaults write com.apple.terminal FocusFollowsMouse -bool false
defaults write org.x.X11 wm_ffm -bool false

# Disable the line marks (square brackets)
defaults write com.apple.Terminal ShowLineMarks -int 0

# Enable Secure Keyboard Entry in Terminal.app
# See: https://security.stackexchange.com/a/47786/8918
defaults write com.apple.terminal SecureKeyboardEntry -bool true

echo "Terminal Config Done. Note that some of these changes require a logout/restart to take effect."
