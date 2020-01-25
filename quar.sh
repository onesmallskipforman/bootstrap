# quarantine function
quar () {

  if [ -z "$2" ]; then
    APP="/Applications/$1.app"
  else
    APP="/$2/$1.app"
  fi

  sudo xattr -r -d com.apple.quarantine "$APP"
}
