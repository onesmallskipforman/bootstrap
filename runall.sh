#!/bin/sh

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

./osxprep.sh
./boostrap.sh
./brew.sh
.config/dock.sh
.config/iterm.sh
.config/osx.sh
.config/safari.sh
.config/terminal.sh
.config/git.sh
.config/docker.sh
.config/firefox.sh   --restore "Backup/Private/Firefox"
.config/minecraft.sh --restore "Backup/Private/Minecraft"
.config/openemu.sh   --restore "Backup/Private/OpenEmu"
.config/slack.sh     --restore "Backup/Private/Slack"
.config/spotify.sh   --restore "Backup/Private/Spofity"
.config/sublime.sh   --restore "Backup/Sublime"
.config/vscode.sh    --restore "Backup/VS Code"
