#!/bin/bash
set -e

# ROS 2 環境をソース
source /opt/ros/humble/setup.bash

# MAVROS 起動
ros2 run mavros mavros_node --ros-args \
   -p fcu_url:="/dev/ttyACM0:57600" \
   -p gcs_url:="udp://0.0.0.0:14551@192.168.2.111:14550"