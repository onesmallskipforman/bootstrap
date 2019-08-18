
# function to check for existence of brew formulae/cask and install if missing
brewcheck () {

  # determine if cask or formulae
  BREW="brew"
  if [[ $1 == "cask" ]]; then BREW="$BREW cask"; shift; fi

  # check for existence of all formulae listed
  for FORM in "$@"
  do                                      # add print if successful
    $BREW ls --versions "$FORM" &>/dev/null 2>&1 || $BREW install "$FORM"
  done
  
}