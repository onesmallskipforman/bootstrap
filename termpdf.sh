#!/bin/zsh

#===================================================================
# termpdf.py Install
#===================================================================

cd "$(dirname $0)"
git clone https://github.com/dsanson/termpdf.py
cd termpdf.py
pip3 install -r requirements.txt
cp -f termpdf.py /usr/local/bin/termpdf.py
rm -rf "$HOME/termpdf.py"
