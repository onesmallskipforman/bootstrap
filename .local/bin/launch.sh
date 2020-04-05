#!/bin/sh

#===============================================================================
# TODO
#===============================================================================

# Function to swap spaces on active displays

#===============================================================================
# NEW SPACES
#===============================================================================

# create new space
function newspace() {
  yabai -m space --create
}

# create new space and focus on new space
function newspace_focus() {
  yabai -m space --create
  index="$(yabai -m query --spaces --display |
           jq 'map(select(."native-fullscreen" == 0))[-1].index')"
  yabai -m space --focus "${index}"
}

# create new space, and move focused window
function newspace_window() {
  WIN_ID=$(yabai -m query --windows --window | jq .id)
  yabai -m space --create
  index="$(yabai -m query --spaces --display |
           jq 'map(select(."native-fullscreen" == 0))[-1].index')"
  yabai -m window "${WIN_ID}" --space "${index}"
}

# create new space, move focused window, and focus on new space
function newspace_window_focus() {
  WIN_ID=$(yabai -m query --windows --window | jq .id)
  yabai -m space --create
  index="$(yabai -m query --spaces --display |
           jq 'map(select(."native-fullscreen" == 0))[-1].index')"
  yabai -m window "${WIN_ID}" --space "${index}"
  yabai -m space --focus "${index}"
}

#===============================================================================
# SPACE TRAVEL
#===============================================================================

# focus space (options: number, next, prev, first, last)
function focus_space() {
  yabai -m space --focus "$1"
}

# move window to space (options: number, next, prev, first, last)
function space_window() {
  WIN_ID=$(yabai -m query --windows --window | jq .id)
  yabai -m window "${WIN_ID}" --space "$1"
}

# move focused window, and focus space
function focus_space_window() {
  WIN_ID=$(yabai -m query --windows --window | jq .id)
  yabai -m window "${WIN_ID}" --space "$1"
  yabai -m space --focus "$1"
}

# In development
# # move space to space
# # TODO: add conditions for jumping spaces on different desktops
# function space_space() {
#   SP_IND=$(yabai -m query --spaces --space | jq .index)
#   yabai -m space "${SP_IND}" --move "$1"
# }

# # move space to space, and focus space
# function space_space() {
#   SP_IND=$(yabai -m query --spaces --space | jq .index)
#   yabai -m space "${SP_IND}" --move "$1"
#   yabai -m space --focus "$1"
# }

#===============================================================================
# DISPLAY TRAVEL
#===============================================================================

# focus space (options: number, next, prev, first, last)
function focus_display() {
  # case "$1" in
  #   "next")
  #     yabai -m display --focus next || yabai -m display --focus first
  #     ;;
  #   "prev")
  #     yabai -m space --focus prev || yabai -m space --focus last
  #     ;;
  #   *)
  #     yabai -m display --focus "$1"
  #     ;;
  # esac
  yabai -m display --focus "$1"
}

# move window to display (options: number, next, prev, first, last)
function display_window() {
  WIN_ID=$(yabai -m query --windows --window | jq .id)
  yabai -m window "${WIN_ID}" --display "$1"
}

# move focused window, and focus space
function focus_display_window() {
  WIN_ID=$(yabai -m query --windows --window | jq .id)
  yabai -m window "${WIN_ID}" --display "$1"
  yabai -m display --focus "$1"
}

# In development
# # move space to display (options: number, next, prev, first, last)
# function display_space() {
#   SP_IND=$(yabai -m query --spaces --space | jq .index)
#   yabai -m space "${SP_IND}" --display "$1"
#   yabai -m display --focus ${index}
# }

# # move focused display, and focus space
# function focus_display_space() {
#   WIN_ID=$(yabai -m query --windows --window | jq .id)
#   yabai -m window "${WIN_ID}" --display "$1"
#   yabai -m display --focus "$1"
# }

#===============================================================================
# WINDOW TRAVEL
#===============================================================================

# focus window (options: prev, next, first, last, recent, mouse, largest, smallest, north, south, east, west, window id)
function focus_window() {
  yabai -m window --focus "$1"
}

# swap windows

# change split

# rotate

# in development
# # focus window directional across all displays
# alt - h : yabai -m window --focus prev ||\
#   ((yabai -m display --focus prev || yabai -m display --focus last) && \
#   yabai -m window --focus last)

# alt - l : yabai -m window --focus next ||\
#   ((yabai -m display --focus next || yabai -m display --focus first) && \
#   yabai -m window --focus first)

# focus window directional across all desktops

#===============================================================================
# LAUNCHERS
#===============================================================================

# use env variable

# if none of the apps on current window are kitty, warp to last


function superkitty () {
  prelen="$(yabai -m query --windows | jq '. | map(select(.app == "kitty")) | length')"
  spaceindex="$(yabai -m query --spaces --space | jq .index)"
  /Applications/kitty.app/Contents/MacOS/kitty -o allow_remote_control=yes --single-instance -d ~ zsh -c "$1" # --title "$title"
  postlen="$(yabai -m query --windows | jq '. | map(select(.app == "kitty")) | length')"
  while [ $prelen -ge $postlen ]
  do
    postlen="$(yabai -m query --windows | jq '. | map(select(.app == "kitty")) | length')"
  done
  id="$(yabai -m query --windows --window | jq .id)"
  # currentindex="$(yabai -m query --spaces --space | jq .index)"
  yabai -m window --space "${spaceindex}"
  yabai -m window --focus "${id}"

  # if [ $spaceindex != currentindex ]
  # then
  #   yabai -m window --warp last
  # fi
}

function supercode () {
  prelen="$(yabai -m query --windows | jq '. | map(select(.app == "Code")) | length')"
  spaceindex="$(yabai -m query --spaces --space | jq .index)"
  code -n
  postlen="$(yabai -m query --windows | jq '. | map(select(.app == "Code")) | length')"
  while [ $prelen -ge $postlen ]
  do
    postlen="$(yabai -m query --windows | jq '. | map(select(.app == "Code")) | length')"
  done
  # id="$(yabai -m query --windows --window | jq .id)"
  # yabai -m window --space "${spaceindex}"
  yabai -m space --focus "${spaceindex}"
  # yabai -m window --focus "${id}"
}

function superff () {
  prelen="$(yabai -m query --windows | jq '. | map(select(.app == "Firefox")) | length')"
  spaceindex="$(yabai -m query --spaces --space | jq .index)"
  open -n "/Applications/Firefox.app/"
  postlen="$(yabai -m query --windows | jq '. | map(select(.app == "Firefox")) | length')"
  while [ $prelen -ge $postlen ]
  do
    postlen="$(yabai -m query --windows | jq '. | map(select(.app == "Firefox")) | length')"
  done
  # id="$(yabai -m query --windows --window | jq .id)"
  # yabai -m window --space "${spaceindex}"
  yabai -m space --focus "${spaceindex}"
  # yabai -m window --focus "${id}"
}

# TODO: write a function that takes a command and runs it with a window wait loop



function showoff () {
  # yabai -m space --create && \
  # yabai -m space --focus last && \
  superkitty "zsh -is eval neofetch --kitty ~/Projects/Dotfiles/sunman.jpeg --size 300px && figlet Hello, Skipper"
  superkitty "zsh -is eval gotop"
  superkitty "zsh -is eval asciiquarium"
  superkitty "zsh -is eval tty-clock -ct"
  superkitty "zsh -is eval pipes.sh"
  yabai -m window --focus first
  # sleep 1
  superkitty "ranger"
  # feh ~/Desktop/sunman.jpeg
}

function battlestation () {

  # new desktops on all displays
  # ndisplays=$(yabai -m query --displays | jq '. | length')

  # yabai -m space --create
  # yabai -m space --create
  # yabai -m space --create

  yabai -m display --focus 1
  yabai -m space --create
  yabai -m space --focus "$(yabai -m query --displays --space | jq '.spaces[-1]')"
  superkitty "zsh -i"

  yabai -m display --focus 2
  yabai -m space --create
  last="$(yabai -m query --displays --space | jq '.spaces[-1]')"
  yabai -m space --focus "${last}"

  # wait for focus
  current="$(yabai -m query --spaces --space | jq '.index')"
  while [ "$current" -ne "$last" ]; do
    current="$(yabai -m query --spaces --space | jq '.index')"
  done

  supercode

  yabai -m display --focus 3
  echo "$(yabai -m query --displays --display | jq '.index')"
  yabai -m space --create
  last="$(yabai -m query --displays --space | jq '.spaces[-1]')"
  yabai -m space --focus "${last}"

  # wait for focus
  current="$(yabai -m query --spaces --space | jq '.index')"
  while [ "$current" -ne "$last" ]; do
    current="$(yabai -m query --spaces --space | jq '.index')"
  done

  superff

}

function clearemptydesktops () {

  # grab current visible desktops, and currently focused desktop
  # visibleids="$(yabai -m query --spaces | jq -r '. | map(select(.visible == 1).id) | .[]')"
  currentid="$(yabai -m query --spaces --space | jq .id)"

  # delete spaces
  yabai -m query --spaces | jq -c '. | map(select(.windows == []).id) | .[]' | while read clearid; do
    clearindex="$(yabai -m query --spaces | jq --argjson clearid $clearid '. | map(select(.id==$clearid))[-1].index')"
    destroydesktop "${clearindex}"
  done

  # find desktops of old visible ids, and focus

  # focus on original id
  index="$(yabai -m query --spaces | jq --argjson currentid $currentid '. | map(select(.id==$currentid))[-1].index')"
  yabai -m space --focus "${index}"
}

function destroydesktop () {
  if [ ! -z "$1" ]; then
    yabai -m space --focus "$1"
    current="$(yabai -m query --spaces --space | jq '.index')"

    while [ "$current" -ne "$1" ]; do
      current="$(yabai -m query --spaces --space | jq '.index')"
    done
  fi

  prelen="$(yabai -m query --spaces | jq '. | length')"
  yabai -m space --destroy
  postlen="$(yabai -m query --spaces | jq '. | length')"

  while [ $prelen -le $postlen ]
  do
    postlen="$(yabai -m query --windows | jq '. | map(select(.app == "kitty")) | length')"
  done
}





# make kitty window, return id
# loop: make kitty window as child of id, return id


# the behavior is the same everywhere. we will just make sure we can warp to current space (display) when we insert a terminal, since terminal insertion is so common
# extend to a keybinding for quickly opening a safari window (command n and send)


# if child of parent window already, dont warp; else warp
# YOU NEED THIS TO WORK IN ALL EDGE CASES
# FOR NOW FILL IN GAPS WITH EASY WINDOW MOVEMENT

# come up with some fixed yabai hierarchy for work/coding setup





# function kittylaunch_i () {
#   # relearn how to insert variables into titles
#   prelen="$(yabai -m query --windows | jq '. | map(select(.title == "kitty")) | length')"
#   parentid="$(yabai -m query --windows --window | jq .id)"
#   # displayindex="$(yabai -m query --displays --display | jq .index)"
#   # kitty --single-instance zsh -is eval "$1" # with zshrc setup
#   # /Applications/kitty.app/Contents/MacOS/kitty -o allow_remote_control=yes --single-instance -d ~ "$1" &
#   /Applications/kitty.app/Contents/MacOS/kitty -o allow_remote_control=yes --single-instance -d ~ "$1" &

#   postlen="$(yabai -m query --windows | jq '. | map(select(.title == "kitty")) | length')"
#   yabai -m --focus "${index}"
#   while [ $prelen -ge $postlen ]
#   do
#     postlen="$(yabai -m query --windows | jq '. | map(select(.title == "kitty")) | length')"
#     yabai -m --focus "${index}"
#   done
#   yabai -m window --warp "${parentid}"
# }

# yabai -m query --spaces --space | jq .index

# function kittylaunch_i () {
#   prelen="$(yabai -m query --spaces --window | jq '.[].windows | length')"
#   index="$(yabai -m query --spaces --display | jq 'map(select(."native-fullscreen" == 0))[-1].index')"
#   # kitty --single-instance zsh -is eval "$1" # with zshrc setup
#   /Applications/kitty.app/Contents/MacOS/kitty -o allow_remote_control=yes --single-instance -d ~ zsh -c "$1; zsh -i" &
#   postlen="$(yabai -m query --spaces --window | jq '.[].windows | length')"
#   yabai -m --focus "${index}"
#   while [ $prelen -ge $postlen ]
#   do
#     postlen="$(yabai -m query --spaces --window | jq '.[].windows | length')"
#     yabai -m --focus "${index}"
#   done
# }


# # add in mechanism to focus to last launched kitty between these to prevent clicking elsewhere from being a problem
# kittylaunch_i asciiquarium
# kittylaunch_i gotop
# kittylaunch_i "tty-clock -ct"
# kittylaunch_i pipes.sh
