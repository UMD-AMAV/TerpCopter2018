# TerpCopter2018
Repository for AMAV team codebase in the 2018 AHS Competition

File Structure:

Top Level: (contains all pertinent project code)
- arduino_files (exist on the Arduino Nano board)
- src (ROS packages)
- simulation

src: (contains all of the ROS packages)
- commander
- arduino
- vision
- px4_interface

TODO:
- merge servo_sweep and servo_act into one node (arduino.cpp)
- create launch flow abstract
- finish node map abstract
