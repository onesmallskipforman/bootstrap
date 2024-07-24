#!/bin/sh

sudo apt -y install qtbase5-dev libqt5svg5-dev libqt5websockets5-dev \
  libqt5opengl5-dev libqt5x11extras5-dev libprotoc-dev libzmq3-dev \
  liblz4-dev libzstd-dev


git -C ~/.local/src clone https://github.com/facontidavide/PlotJuggler.git
cd ~/.local/src/PlotJuggler

cmake -S ~/.local/src/PlotJuggler -B ~/.local/src/PlotJuggler/build/PlotJuggler -DCMAKE_INSTALL_PREFIX=install
cmake --build ~/.local/src/PlotJuggler/build/PlotJuggler --config RelWithDebInfo --target install


# install ros plugin
# sudo apt install ros-${ROS_DISTRO}-plotjuggler-ros
