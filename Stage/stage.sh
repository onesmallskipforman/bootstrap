#!/bin/bash

mkdir -p ../Lists

jq -r '.tap[]'    apps.json > ../Lists/tap.txt
jq -r '.brew[]'   apps.json > ../Lists/brew.txt
jq -r '.cask[]'   apps.json > ../Lists/cask.txt
jq -r '.mas[].id' apps.json > ../Lists/mas.txt
jq -r '.pip3[]'   apps.json > ../Lists/pip3.txt
jq -r '.npm[]'    apps.json > ../Lists/npm.txt

jq -r '.tap[] | "tap \"\(.)\""' apps.json > ../Lists/Brewfile; echo >> ../Lists/Brewfile
jq -r '.brew[] | "brew \"\(.)\""' apps.json >> ../Lists/Brewfile; echo >> ../Lists/Brewfile
jq -r '.cask[] | "cask \"\(.)\""' apps.json >> ../Lists/Brewfile; echo >> ../Lists/Brewfile
jq -r '.mas[] | "mas \"\(.name)\", id: \(.id)"' apps.json >> ../Lists/Brewfile
