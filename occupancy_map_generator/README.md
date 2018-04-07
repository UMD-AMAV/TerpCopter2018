
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
rostopic echo OccupancyGrid
//////////////////////////////////////////////

Run rviz to visualize occupancy grid data:
```
rosrun rviz rviz

### Using tf tools
Launch demo:
'''
roslaunch turtle_tf turtle_tf_demo.launch

Check rotational matrix:
'''
rosrun tf tf_echo turtle1 turtle2

Show tf graph:
'''
rosrun rqt_tf_tree rqt_tf_tree