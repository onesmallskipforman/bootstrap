!/bin/sh


DISPLAYS=$(xrandr -q | grep -E '(dis)?connected' | awk '{print $1}')

CONNECTED=$(xrandr -q | grep -E '\<connected\>' | awk '{print $1}')
OFF=$(xrandr -q | grep -E 'disconnected' | awk '{print "--output "$1" --off"}' | xargs -n1 -i echo --output {} --off)

ON=$(xrandr -q | grep -E '\<connected\>' | sed 's/primary//g' |  awk '{print "--output "$1,"--mode "$3" --rotate normal"}')
