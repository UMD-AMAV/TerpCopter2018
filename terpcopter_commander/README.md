
# Terpcopter Commander Offboard mode

Offboard control using [ROS](http://www.ros.org) and [MAVROS](https://github.com/mavlink/mavros) for [PX4](https://github.com/PX4/Firmware).

The initial implementation is taken from the [MAVROS offboard control example](http://dev.px4.io/ros-mavros-offboard.html).

## Usage

### Dependencies

- [ROS](http://www.ros.org)
- [MAVROS](https://github.com/mavlink/mavros)
- [Catkin workspace](http://wiki.ros.org/catkin/Tutorials/create_a_workspace)

### Building

```
cd ~/wherever/
git clone 
cd ~/catkin_ws
catkin build
```

### Running In Simulation

Start PX4 with (from ~/src/Firmware) e.g.:
```
make posix gazebo
```

Then start MAVROS (from anywhere):

```
roslaunch mavros px4.launch fcu_url:="udp://:14540@14557"
```

And launch terpcopter:
```
roslaunch terpcopter_commander terpcopter_commander.launch
```
run offboard mode:
```
rosrun mavros mavsys mode -c OFFBOARD
```
arm the vechile:
```
rosrun mavros mavsafety arm
```
Running In Live Flight Test

First launch mavros
'''
roslaunch mavros px4.launch
```
And launch terpcopter:
```
roslaunch terpcopter_commander terpcopter_commander.launch
```
run offboard mode:
```
rosrun mavros mavsys mode -c OFFBOARD
```
arm the vechile:
```
rosrun mavros mavsafety arm
'''
### Service Test
```
rossrv show [service name]
```
```
rosservice call [service name] [arg]
```

