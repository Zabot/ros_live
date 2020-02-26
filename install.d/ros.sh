#!/bin/sh

apt install gnupg -y
echo "deb http://packages.ros.org/ros/ubuntu stretch main" \
  > /etc/apt/sources.list.d/ros-latest.list
apt-key adv --keyserver hkp://ha.pool.sks-keyservers.net:80 \
  --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654
apt update

apt install ros-melodic-desktop-full python-catkin-tools -y
rosdep init

