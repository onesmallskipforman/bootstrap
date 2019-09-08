
# generic restore and backup function for a given app support folder
sync () {

  SUPPORT="$2"
  BACKUP="$3"

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



