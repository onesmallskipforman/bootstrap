#!/bin/sh

# NOTE: this should work but does not. using --pip-args prevents pipx from deducing the name of the package when installing this local directory
# pipx install --force $DIR --pip-args "-r $DIR/misc/requirements/requirements-pyqt-6.4-txt"
# same with this. inject's --pip-args doesn't allow multiple args
# pipx install --force $DIR
# pipx inject --force qutebrowser --pip-args "-r $DIR/misc/requirements/requirements-pyqt-6.4-txt"
# and this. for some reason pytqt6-qt6's version is just wrong. it's not the version in the requirements file. you have to inject twice for some reason
# pipx install --force $DIR && pipx inject --force qutebrowser -r $DIR/misc/requirements/requirements-pyqt-6.4-txt
# but this works, and honestly feels the closes to a regular pip install
# pipx install --force $DIR
# pipx runpip qutebrowser install -r $DIR/misc/requirements/requirements-pyqt-6.4.txt
# alternatively you could try merging all requirements
# cat $DIR/misc/requirements/requirements-pyqt-6.4-txt >> $DIR/requirements.txt
# pipx install --force $DIR
# also worth noting that package name deduction doesn't work with older pip versions
# so you need
# ~/.local/share/pipx/shared/bin/pip install -U pip

# TODO: move away from pipx

sudo apt install -qy --no-install-recommends git ca-certificates python3 python3-venv \
  libgl1 libxkbcommon-x11-0 libegl1-mesa libfontconfig1 libglib2.0-0 \
  libdbus-1-3 libxcb-cursor0 libxcb-icccm4 libxcb-keysyms1 libxcb-shape0 \
  libnss3 libxcomposite1 libxdamage1 libxrender1 libxrandr2 libxtst6 libxi6 \
  libasound2

URL='https://github.com/qutebrowser/qutebrowser/releases/download/v3.2.1/qutebrowser-3.2.1.tar.gz'
DIR=$(mktemp -d)

python3 -m pip install -U --user pipx
~/.local/share/pipx/shared/bin/pip install -U pip
wget -qO- $URL | tar xvz -C $DIR --strip-components=1
pipx install --force $DIR
pipx runpip qutebrowser install -r $DIR/misc/requirements/requirements-pyqt-6.4.txt
cp $DIR/misc/org.qutebrowser.qutebrowser.desktop $XDG_DATA_HOME/applications


# to uninstall
# pipx uninstall qutebrowser
# rm $XDG_DATA_HOME/applications/org.qutebrowser.qutebrowser.desktop
