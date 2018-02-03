
//
// THIS HEADER FILE CONTAINS LIBRARIES AND FUNCTION FOR OFFBOARD MISSION
//
// COPYRIGHT BELONGS TO THE AUTHOR OF THIS CODE
//
// AUTHOR : SAIMOULI KATRAGADA
// AFFILIATION : UNIVERSITY OF MARYLAND 
// EMAIL : SKATRAGA@TERPMAIL.UMD.EDU
//
// THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THE GPLv3 LICENSE
// THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. ANY USE OF
// THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
// PROHIBITED.
// 
// BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO
// BE BOUND BY THE TERMS OF THIS LICENSE. THE LICENSOR GRANTS YOU THE RIGHTS
// CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH TERMS AND
// CONDITIONS.
//

///////////////////////////////////////////
//
//	LIBRARIES
//
/////////////////////////////////////////// 
#pragma once

#include <ros/ros.h>
#include <string>

#include <geometry_msgs/PoseStamped.h>
#include <mavros_msgs/CommandBool.h>
#include <mavros_msgs/SetMode.h>
#include <mavros_msgs/State.h>
#include <nav_msgs/Odometry.h>
#include <mavros_msgs/AttitudeTarget.h>
#include <mavros_msgs/PositionTarget.h>
#include <tf/tf.h>
#include <tf/transform_broadcaster.h>


#define MISSION_NODE "offb"

class TerpCopterMission {
    public: 

    // Messages
    mavros_msgs::State current_state;
    geometry_msgs::PoseStamped pose;
    nav_msgs::Odometry current_odom;
    mavros_msgs::PositionTarget orient;

    // Node handler
    ros::NodeHandle nh;

    // Publishers
    ros::Publisher local_pos_pub;

    // Callbacks
    void state_cb(const mavros_msgs::State::ConstPtr& msg);
    void state_cu(const nav_msgs::Odometry::ConstPtr& msgS);

    // Callbacks for autonomy
    void hover (float);
    void move (float, float, float);
    void yaw (float,float);
    // bool isReachedPos ();
    // bool isReachedOri ();

};