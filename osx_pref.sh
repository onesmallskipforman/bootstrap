#!/bin/bash


# Turn Dark mode on (unfortunately have to disable system identity protection to use defaults)
osascript -e 'tell app "System Events" to tell appearance preferences to set dark mode to true'

# Add develop menu for safari
defaults write com.apple.Safari IncludeDevelopMenu 1