#!/bin/bash

#===================================================================
# APP BACKUP SCRIPT
#===================================================================

bash Sync/sync_ff.sh --backup
bash Sync/sync_mc.sh --backup
bash Sync/sync_emu.sh --backup
bash Sync/sync_slack.sh --backup
bash Sync/sync_spotify.sh --backup
