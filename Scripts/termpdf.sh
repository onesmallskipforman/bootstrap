#!/bin/sh

#===================================================================
# termpdf.py Install
#===================================================================

git clone https://github.com/dsanson/termpdf.py
cd termpdf.py
pip3 install -r requirements.txt
cp -f termpdf.py /usr/local/bin/termpdf.py
rm -rf "termpdf.py"
