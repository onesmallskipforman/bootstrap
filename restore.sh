#!/bin/bash

#===================================================================
# APP RESTORE SCRIPT
#===================================================================

bash Sync/sync_ff.sh --restore
bash Sync/sync_mc.sh --restore
bash Sync/sync_emu.sh --restore
bash Sync/sync_slack.sh --restore
bash Sync/sync_spotify.sh --restore
