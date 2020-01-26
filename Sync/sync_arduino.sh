#!/bin/bash

# arduino libraries restore and backup function

source Sync/sync.sh

# library and backup directories
LIB="$HOME/Documents/Arduino"
BACKUP="Backups/Arduino"

# use generic config function
sync $1 "$LIB" "$BACKUP"
echo "Arduino library restore done. Note that some of these changes require a logout/restart to take effect."
