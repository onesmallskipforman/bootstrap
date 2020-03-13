#!/bin/sh


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
  /Applications/Firefox.app/Contents/MacOS/firefox -new-window &
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




function showoff () {
  # yabai -m space --create && \
  # yabai -m space --focus last && \
  superkitty "neofetch --kitty ~/Projects/Dotfiles/sunman.jpeg --size 300px && figlet Hello, Skipper; zsh -i"
  superkitty "gotop; zsh -i"
  superkitty "asciiquarium; zsh -i"
  superkitty "tty-clock -ct; zsh -i"
  superkitty "pipes.sh; zsh -i"
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


function windowdeltadisplay () {
  displayindex="$(yabai -m query --displays --display | jq .index)"
  maxindex="$(yabai -m query --displays | jq '. | map(.index) | max')"
  minindex="$(yabai -m query --displays | jq '. | map(.index) | min')"

  if [ $displayindex = $maxindex ]; then
    nextind="${minindex}"
  else
    nextind="$(($displayindex+1))"
  fi

  if [ $displayindex = $minindex ]; then
    prevind="${maxindex}"
  else
    prevind="$(($displayindex-1))"
  fi
  # && "prev"

  if [ "$1" = "next" ]; then
    newind="${nextind}"
  elif [ "$1" = "prev"  ]; then
    newind="${prevind}"
  fi

  yabai -m window --display "${newind}"

  if [ "$2" = "follow" ]; then
    yabai -m display --focus "${newind}"
  else
    yabai -m display --focus "${displayindex}"
  fi

}

function windowdeltadisplay_n () {
  yabai -m window --display "$1"
  if [ "$2" = "follow" ]; then yabai -m display --focus "$1"; fi
}


function clearemptydesktops () {
  emptyindecies="$(yabai -m query --spaces | jq -c '. | map(select(.windows == []).index) | .[]')"
  echo "${emptyindecies}" | while read object; do
    :
  done
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



# TODO: fix cleardesktops


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




# yabai -m window --focus recent
# yabai -m window --focus first
# yabai -m window --focus last
