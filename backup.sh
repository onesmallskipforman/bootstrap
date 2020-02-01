#!/bin/sh

#===================================================================
# BACKUP INSTALLS
#===================================================================

# backup taps
# backup formulae
# backup casks
# backup mas's
# backup npm's
# backup pip3 libraries

#===================================================================
# APP SUPPORT BACKUPS
#===================================================================

bash .config/sync_ff.sh      --backup
bash .config/sync_mc.sh      --backup
bash .config/sync_emu.sh     --backup
bash .config/sync_slack.sh   --backup
bash .config/sync_spotify.sh --backup
