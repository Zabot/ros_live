# Source ROS workspaces if they exist
if [[ -f /opt/ros/melodic/setup.bash ]]; then
    source /opt/ros/melodic/setup.bash
fi

if [[ -f $HOME/catkin_ws/devel/setup.bash ]]; then
    source $HOME/catkin_ws/devel/setup.bash
fi

export ROS_MASTER_URI="http://localhost:11311"

