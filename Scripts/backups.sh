#!/bin/zsh

#===============================================================================
# SETUP BACKUP STORAGE
#===============================================================================

REPO="https://github.com/onesmallskipforman/Backup.git"
BACKUP="$XDG_DATA_HOME"
mkdir -p "$BACKUP"

git -C "$BACKUP" init
git -C "$BACKUP" remote add origin "$REPO"
git -C "$BACKUP" pull origin master
git -C "$BACKUP" clean -fdX
