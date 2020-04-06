#!/bin/zsh

# Folders
CONFIG="$HOME/config/refind"
REFDIR="/Volumes/ESP/EFI/refind"

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until the script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# if not installed or forced, run install prep
rm -rf $CONFIG/refind-bin*
wget -O $CONFIG/refind.zip https://sourceforge.net/projects/refind/files/latest/download
unzip $CONFIG/refind.zip -d $CONFIG/
rm $CONFIG/refind.zip
sudo $CONFIG/refind-bin*/mountesp
rm -rf "$REFDIR"

# install/upgrade
sudo $CONFIG/refind-bin*/refind-install

# clean upgrade contents, copy refind.conf
rm -f "$REFDIR/refind.conf-sample"
rm -rf "$REFDIR/icons-backup"
cp "$CONFIG/refind.conf" "$REFDIR/refind.conf"

# install themes
mkdir "$REFDIR/themes"

# major theme
# git clone https://github.com/kgoettler/ursamajor-rEFInd.git "$REFDIR/themes/rEFInd-minimal-black"
# echo "include themes/ursamajor-rEFInd/theme.conf" >> "$REFDIR/refind.conf"

# minimalist black theme
# git clone https://github.com/andersfischernielsen/rEFInd-minimal-black "$REFDIR/themes/rEFInd-minimal-black"
# echo "include themes/rEFInd-minimal-black/theme.conf" >> "$REFDIR/refind.conf"

# refind theme Regular
git clone https://github.com/bobafetthotmail/refind-theme-regular.git "$REFDIR/themes/refind-theme-regular"
echo "include themes/refind-theme-regular/theme.conf" >> "$REFDIR/refind.conf"
cp "$CONFIG/theme.conf" "$REFDIR/themes/refind-theme-regular/theme.conf"

# unmount ESP/EFI
sudo diskutil unmount /Volumes/ESP
