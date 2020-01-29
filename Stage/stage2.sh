#!/usr/bin/sh


jq -r '.tap[]'     apps.json > tap.txt
jq -r '.brew[]'    apps.json > brew.txt
jq -r '.cask[]'    apps.json > cask.txt
jq -r '.mas[]|.id' apps.json > mas.txt
jq -r '.pip3[]'    apps.json > pip3.txt
jq -r '.npm[]'     apps.json > npm.txt







brew tap
brew install
brew cask install
mas install
pip3 install
npm -g install



bash
python3



# {
#     "name": "Brewfile",
#     "title": "BREW BUNDLE FILE"
#   },


  # {
  #   "tag": "commandlinetools",
  #   "installName": "clinetools.sh"
  # },
