#!/bin/bash

# slack restore and backup

source Sync/sync.sh

sync $1 "$HOME/Library/Application Support/Slack" "Backups/Slack"
echo "Slack library restore done. Note that some of these changes require a logout/restart to take effect."