#!/usr/bin/env bash

# Set RL launch options to `"/path/to/this/script.sh" & %command%`
# Put any other launch options before `%command%` like normal
# Set Wineprefix for Rocket League
COMPATDATA="$HOME/.steam/debian-installation/steamapps/compatdata/252950/pfx"

# Hardcode Proton Path
# PROTON="$HOME/.steam/debian-installation/steamapps/common/Proton - Experimental/files"
PROTON="$HOME/.steam/debian-installation/steamapps/common/Proton 7.0/dist"
# PROTON="$HOME/.steam/debian-installation/steamapps/common/Proton 6.3/dist"
# Start BakkesMod when RL Starts
while ! killall -0 RocketLeague.ex 2> /dev/null; do
    sleep 1
done

# Open BakkesMod with above wineprefix and proton
## IMPORTANT! MAKE SURE YOU ENABLE WINE E/F SYNC HERE, DEPENDING ON YOUR NEEDS!
# WINEFSYNC=1 WINEPREFIX="$COMPATDATA" "$PROTON"/bin/wine64 "$COMPATDATA/drive_c/Program Files/BakkesMod/BakkesMod.exe"
WINEESYNC=1 WINEPREFIX="$COMPATDATA" "$PROTON"/bin/wine64 "$COMPATDATA/drive_c/Program Files/BakkesMod/BakkesMod.exe" &
# WINEPREFIX="$COMPATDATA" "$PROTON"/bin/wine64 "$COMPATDATA/drive_c/Program Files/BakkesMod/BakkesMod.exe"
# WINEFSYNC=1 WINEESYNC=1 WINEPREFIX="$COMPATDATA" "$PROTON"/bin/wine64 "$COMPATDATA/drive_c/Program Files/BakkesMod/BakkesMod.exe"

# Kill BakkesMod process when RL is closed
while killall -0 RocketLeague.ex 2> /dev/null; do
    sleep 1
done
killall BakkesMod.exe
