Includes the ROS autonomy nodes for AMAV challenge

Add the offb_pkg folder to the src folder inside your catkin workspace. Use catkin_make_isolated to build. The C++ files inside the src folder are used to make the drone simulation in Gazebo perform certain actions. The actions are:

offb.cpp - Hover at a certain altitude.
Traj_Follow.cpp - Follow a circular trajectory at a given altitude.
Straight_Line.cpp - Accepts an input for the a point in the world frame and makes the drone travel to that point in a straight line.
The scripts folder contains the opencv ROS codes to detect the Red circles and the Black squares targets. The programs require another node that publishes to the /CompressedImage topic. This was done through an Android App. The reader can easily adopt the logic from the program.

STEPS TO LAUNCH SIMULATION: Note that these steps have to be performed after following the installation procedures given here.

Follow the tutorials in that link and install ROS, Gazebo and the required dependencies. Then to launch the simulation:

METHOD 1:
```
cd src/Firmware
make posix_sitl_default gazebo
```

Method 2:
```
source ~/catkin_ws/devel/setup.bash
source Tools/setup_gazebo.bash $(pwd) $(pwd)/build/posix_sitl_default
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)
export ROS_PACKAGE_PATH=$ROS_PACKAGE_PATH:$(pwd)/Tools/sitl_gazebo
roslaunch px4 posix_sitl.launch
```

Method 3 (launch individually): Launch SITL first
```
cd src/Firmware
no_sim=1 make posix_sitl_default gazebo
```
In a new tab launch Gazebo

```
cd src/Firmware
source Tools/setup_gazebo.bash $(pwd) $(pwd)/build/posix_sitl_default
roslaunch gazebo_ros empty_world.launch world_name:=$(pwd)/Tools/sitl_gazebo/worlds/iris.world
```

Launching MAVROS after launching the simulation using any one of the above methods:
```
source /opt/ros/kinetic/setup.bash
ls /opt/ros/kinetic/lib/mavros
roslaunch mavros px4.launch fcu_url:="udp://:14540@127.0.0.1:14557"
```
Then Launch any of the nodes inside the offb_pkg package using rosrun command.
