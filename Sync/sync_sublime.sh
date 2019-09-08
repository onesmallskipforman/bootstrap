#!/bin/bash

# spotify restore and backup

source Sync/sync.sh

sync $1 "$HOME/Library/Application Support/Sublime Text 3" "Backups/Sublime"
echo "Sublime library restore done. Note that some of these changes require a logout/restart to take effect."