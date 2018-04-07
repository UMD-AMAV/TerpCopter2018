
# Occupancy Map Generator

Offboard control using [ROS](http://www.ros.org) and [TF](https://github.com/ros/geometry/tree/indigo-devel/tf) and [NAV](https://github.com/ros-planning/navigation).

## Usage

### Dependencies

- [ROS](http://www.ros.org)
- [NAV](https://github.com/ros-planning/navigation)
- [Catkin workspace](http://wiki.ros.org/catkin/Tutorials/create_a_workspace)

### Building

```
cd ~/wherever/
git clone 
cd ~/catkin_ws
catkin build
```

### Running
Launch core:
'''
roscore
///////////////////////////////////////////////

Run occu_map_generator node:
```
rosrun occupancy_map_generator occu_map_generator
///////////////////////////////////////////////

Check occupancy_grid publish:
```
rostopic echo occupancy_grid
//////////////////////////////////////////////

Run rviz to visualize occupancy grid data:
```
rosrun rviz rviz