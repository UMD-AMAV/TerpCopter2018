cmake_minimum_required(VERSION 2.8.3)
project(terpcopter_comm)

find_package(catkin REQUIRED COMPONENTS geometry_msgs std_msgs message_generation sensor_msgs)

## Find catkin macros and libraries
## if COMPONENTS list like find_package(catkin REQUIRED COMPONENTS xyz)
## is used, also find other catkin packages
find_package(catkin REQUIRED COMPONENTS
  message_generation
  roscpp
  rospy
  std_msgs
)

## Generate messages in the 'msg' folder
add_message_files(
  DIRECTORY msg
  FILES
  Health.msg
  CameraInfo.msg
  Mavlink.msg
  OpticalFlow.msg
  ObstacleDetection.msg
)

add_service_files(
  DIRECTORY srv
  FILES SetCameraInfo.srv DetectObject.srv ServoSweep.srv
)

generate_messages(
  DEPENDENCIES
  geometry_msgs
  std_msgs
  sensor_msgs
  ${MSG_DEP_SET}
)


# if RTI DDS is found
if(DEFINED ENV{NDDSHOME})
  catkin_package(
    INCLUDE_DIRS include
    LIBRARIES terpcopter_comm_dds
    CATKIN_DEPENDS message_runtime
  )

  set(NDDSHOME $ENV{NDDSHOME})

  include_directories(
    include
    include/terpcopter_comm
    ${NDDSHOME}/include
    ${NDDSHOME}/include/ndds
  )

  add_definitions(-DRTI_UNIX)

  add_library(terpcopter_comm_dds
    dds_msg/DDSImage.cxx
    dds_msg/DDSImagePlugin.cxx
    dds_msg/DDSImageSupport.cxx
  )
else()
  catkin_package(
    INCLUDE_DIRS include
    CATKIN_DEPENDS message_runtime std_msgs ${MSG_DEP_SET}
  )
endif()
