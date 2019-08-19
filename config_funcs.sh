

# quarantine function
quar () {

  if [ -z "$2" ]; then
    APP="/Applications/$1*.app"
  else
    APP="/$2/$1.app"
  fi
  
  sudo xattr -r -d com.apple.quarantine "$APP"
} 

# restore and backup function
config () {

  SUPPORT=~/"Library/Application Support/$2"
  BACKUP="Backups/$2"

  if [[ $1 == "--backup" ]]; then
    # copy support over, (TODO) encrypt and backup to cloud
    mkdir -p "$BACKUP/" && 
    cp -r "$SUPPORT/" "$BACKUP/"
  elif [[ $1 == "--restore" ]]; then
    # (TODO) grab backup, decrypt, remove old profile, copy
    rm -rf "$SUPPORT"
    cp -r "$BACKUP/" "$SUPPORT/"
  else
    echo "Invalid Config Option"
  fi

}

# openemu restore and backup function
config_emu () {

  SUPPORT=~/"Library/Application Support/OpenEmu"
  BACKUP="Backups/OpenEmu"

  config $1 "OpenEmu"

  if [[ $1 == "--backup" ]]; then
    # remove glitchy save states (could do this during restore)
    rm -rf "$BACKUP/Save States"
  fi
  
}

# firefox restore and backup function
config_ff () {

  SUPPORT=~/"Library/Application Support/Firefox"
  BACKUP="Backups/Firefox"
  APP="/Applications/Firefox.app"
  CLI="$APP/Contents/MacOS/firefox"
  URL="about:addons"

  if [[ $1 == "--backup" ]]; then
    # copy profile over
    PROFILE="$SUPPORT/Profiles/"*.default-release
    mkdir -p "$BACKUP/" && 
    cp -r "$SUPPORT/Profiles/"*.default-release "$BACKUP/"
  elif [[ $1 == "--restore" ]]; then
    # remove old profile folders
    rm -rf "$SUPPORT"

    # create profile
    "$CLI" -CreateProfile default-release
    # PROFILE="$SUPPORT/Profiles/"*.default-release

    # copy backup to profile 
    cp -r "$BACKUP/" "$SUPPORT/Profiles/"*.default-release

    echo "Setting Up Firefox"

    # run profile headless, trigger default browser dialoge and wait 60 seconds
    "$CLI" "$URL" -headless &>/dev/null & #-setDefaultBrowser
    sleep 60
    osascript -e 'quit app "Firefox"'
  else
    echo "Invalid Config Option"
  fi

}

# arduino restore and backup function
config_ino () {

  # library and backup directories
  LIB=~/"Documents/Arduino"
  BACKUP="Backups/Arduino"

  if [[ $1 == "--backup" ]]; then
    # copy library over
    mkdir -p "$BACKUP/" && 
    cp -r "$LIB/" "$BACKUP/"
  elif [[ $1 == "--restore" ]]; then
    # remove old library folders
    rm -rf "$LIB"

    # copy support folder
    yes | cp -rf "$BACKUP/" "$LIB/"
  else
    echo "Invalid Config Option"
  fi
} 




