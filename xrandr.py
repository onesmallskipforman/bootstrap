#!/usr/bin/python3

import os

# class Display:

#   def __init__(self, res)

#   self.res = ()

# edp1 = Display(2560, 1600)


# tuning parameters
dpi = 96 # 96
# e1res = (2560, 1600)
e1res = (1920, 1200)
h1res = (1920, 1080)
p = 0 # percentage of how much scaling is being done to the externals and how much to the internal

pe = 0.6 # percentage of how much we are honoring the prescribed internal scaling
ph = 1.0 # percentage of how much we are honoring the prescribed external scaling

e1ymm = 179
h1ymm = 340

scale0 = e1res[1]/h1res[1] * h1ymm/e1ymm


scale = p*(scale0 - 1) + 1
scaleE= (1-p)*(1/scale0-1) + 1


scale = (scale-1)*ph + 1
scaleE = (scaleE-1)*pe + 1

print(scale, scaleE)

e1pan = (e1res[0]*scaleE, e1res[1]*scaleE, 0, 0)

# difftopmm = 80
# shift = -e1res[1]*difftopmm/e1ymm
shift = (e1pan[1] - h1res[1]*scale)/2.0
# shift = 0
h1pos = (e1pan[0], shift)
h1pan = (h1res[0]*scale, h1res[1]*scale, h1pos[0], 0)

h2pos = (e1pan[0] + h1pan[0], 0)
h2pan = (h1pan[0], h1pan[1], h2pos[0], 0)

fb = tuple(sum(i) for i in zip(e1pan, h1pan, h2pan))

print(fb)


def runandprint(cmd):
  cmd_formatted = ' '.join(cmd.split())
  print(cmd_formatted + "\n")
  os.system(cmd_formatted)

def display(id, res, scale, pos, pan):
  pan = (0,0,0,0)
  runandprint(
    """
      xrandr
      --output    {}
        --mode    {}x{}
        --scale   {:.3F}x{:.3F}
        --pos     {}x{}
        --panning {}x{}+{}+{} --fb {}x{}
    """.format(id, *res, scale, scale, *pos, *pan,  int(fb[0]) + 1, int(fb[1]) + 1)
  )


runandprint("echo \"Xft.dpi: {}\" | xrdb -merge && xrandr --dpi {} --fb {}x{}".format(dpi, dpi,  int(fb[0]) + 1, int(fb[1]) + 1))
# runandprint("xrandr --dpi 96")

display(
  "eDP-1",
  (int(e1res[0]), int(e1res[1])),
  scaleE,
  (0,0),
  (int(e1pan[0]), int(e1pan[1]), int(e1pan[2]), int(e1pan[3])),
)

display(
  "HDMI-1",
  (int(h1res[0]), int(h1res[1])),
  scale,
  (int(h1pos[0]) + 1, int(h1pos[1])),
  (int(h1pan[0]), int(h1pan[1]), int(h1pan[2]), int(h1pan[3])),
)

display(
  "HDMI-2",
  (int(h1res[0]), int(h1res[1])),
  scale,
  (int(h2pos[0]) + 2, int(h2pos[1])),
  (int(h2pan[0]), int(h2pan[1]), int(h2pan[2]), int(h2pan[3])),
)

runandprint("i3-msg restart")


# runandprint(
#   """
# xrandr \
# --dpi {} \
# --output eDP-1 \
#   --primary \
#   --mode {}x{} \
#   --pos 0x0 \
#   --scale {:.3F}x{:.3F} \
#   --panning {}x{}+{}+{} \
# --output HDMI-1 \
#   --mode {}x{} \
#   --pos {}x{} \
#   --scale {:.3F}x{:.3F} \
#   --panning {}x{}+{}+{} \
# --output HDMI-2 --off \
#   --mode {}x{} \
#   --pos {}x{} \
#   --scale {:.3F}x{:.3F} \
#   --panning {}x{}+{}+{}
#   """.format(
#     dpi,
#     int(e1res[0]),
#     int(e1res[1]),
#     scaleE,
#     scaleE,
#     int(e1pan[0]),
#     int(e1pan[1]),
#     int(e1pan[2]),
#     int(e1pan[3]),
#     int(h1res[0]),
#     int(h1res[1]),
#     int(h1pos[0]),
#     int(h1pos[1]),
#     scale,
#     scale,
#     int(h1pan[0]),
#     int(h1pan[1]),
#     int(h1pan[2]),
#     int(h1pan[3]),
#     int(h1res[0]),
#     int(h1res[1]),
#     int(h2pos[0]) + 1,
#     int(h2pos[1]),
#     scale,
#     scale,
#     int(h2pan[0]),
#     int(h2pan[1]),
#     int(h2pan[2]),
#     int(h2pan[3]),
#   )
# )





# os.system("xrandr --fb ")


# xrandr --dpi 96 --output eDP-1 --primary --auto --pos 0x0 --output HDMI-1 --auto --pos 2560x-715 --scale 2.812x2.812 --panning 5400x3037+2560+0
