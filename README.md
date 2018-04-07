# TerpCopter2018

### Dependencies

- [ROS](http://www.ros.org)
- [MAVROS](https://github.com/mavlink/mavros)
- [PX4](https://docs.px4.io/)
- [OpenCV](https://opencv.org/)
- [MatLab](https://www.mathworks.com/products/matlab.html)

### Running

Start MAVROS (from anywhere):

```
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
```
### Service Test
```
rossrv show [service name]
```
```
rosservice call [service name] [arg]
```
### Tools
- HSV trackbar tuner 
- Ros bag message to csv python scripts
