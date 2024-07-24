#!/bin/sh

. ~/.cache/wal/colors.sh

/usr/bin/i3lock --nofork                   \
    --ignore-empty-password   \
    \
    --indicator       \
    --bar-indicator     \
    --bar-pos="1070"   \
    --bar-base-width="10"   \
    --bar-orientation=horizontal  \
    --bar-color=2e3440      \
    --ringver-color=88c0d0   \
    --ringwrong-color=bf616a   \
    --bshl-color=5e81ac      \
    --keyhl-color=a3be8c     \
    \
    --clock       \
    --time-color=eceff4ff    \
    --time-str="%I:%M %p"    \
    --time-font="Hack Nerd Font" \
    --time-size=150      \
    --time-pos="1500:875"    \
    --time-color=2e3440ff    \
    \
    --date-color=d8dee9ff    \
    --date-str="%A, %d %B"   \
    --date-color=2e3440ff    \
    --date-font="Hack Nerd Font" \
    --date-size=95     \
    --date-pos="tx:1020" \
    \
    --verif-font="Hack Nerd Font"  \
    --verif-size=150     \
    --verif-text="Welcome home!"   \
    --wrong-font="Hack Nerd Font"  \
    --wrong-size=150     \
    --wrong-text="No Entry!"   \
    \
    --image=$HOME/.local/share/wallpapers/pink-and-green-background-52ldpogdznstvr91.png --fill
    # --image=$HOME/pictures/wallpapers/nord_calvin-and-hobbes.png
