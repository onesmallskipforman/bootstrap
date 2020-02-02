#!/bin/bash

DIR="../../Backup/Brew"

jq -r '.tap[]'    apps.json > DIR/tap.txt
jq -r '.brew[]'   apps.json > DIR/brew.txt
jq -r '.cask[]'   apps.json > DIR/cask.txt
jq -r '.mas[].id' apps.json > DIR/mas.txt
jq -r '.pip3[]'   apps.json > DIR/pip3.txt
jq -r '.npm[]'    apps.json > DIR/npm.txt

jq -r '.tap[] | "tap \"\(.)\""'   apps.json && echo "" >  DIR/Brewfile;
jq -r '.brew[] | "brew \"\(.)\""' apps.json && echo "" >> DIR/Brewfile;
jq -r '.cask[] | "cask \"\(.)\""' apps.json && echo "" >> DIR/Brewfile;
jq -r '.mas[] | "mas \"\(.name)\", id: \(.id)"' apps.json >> DIR/Brewfile
