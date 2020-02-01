#!/bin/bash

mkdir -p ../Lists

jq -r '.tap[]'    apps.json > tap.txt
jq -r '.brew[]'   apps.json > brew.txt
jq -r '.cask[]'   apps.json > cask.txt
jq -r '.mas[].id' apps.json > mas.txt
jq -r '.pip3[]'   apps.json > pip3.txt
jq -r '.npm[]'    apps.json > npm.txt

jq -r '.tap[] | "tap \"\(.)\""' apps.json > Brewfile; echo >> Brewfile
jq -r '.brew[] | "brew \"\(.)\""' apps.json >> Brewfile; echo >> Brewfile
jq -r '.cask[] | "cask \"\(.)\""' apps.json >> Brewfile; echo >> Brewfile
jq -r '.mas[] | "mas \"\(.name)\", id: \(.id)"' apps.json >> Brewfile
