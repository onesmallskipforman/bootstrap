#!/bin/bash

# ensure app is not running
pkill -a OpenEmu
# osascript -e 'quit app "OpenEmu"'

source Sync/sync.sh

# support and backup directories
SUPPORT="$HOME/Library/Application Support/OpenEmu"
BACKUP="Backups/OpenEmu"

sync $1 "$SUPPORT" "$BACKUP"

if [[ $1 == "--backup" ]]; then
  # remove glitchy save states (could do this during restore)
  rm -rf "Backups/OpenEmu/Save States"
fi

echo "OpenEmu library restore done. Note that some of these changes require a logout/restart to take effect."
