#!/bin/bash

# minecraft restore and backups

source Sync/sync.sh

sync $1 "$HOME/Library/Application Support/Minecraft" "Backups/Minecraft"
echo "Minecraft library restore done. Note that some of these changes require a logout/restart to take effect."