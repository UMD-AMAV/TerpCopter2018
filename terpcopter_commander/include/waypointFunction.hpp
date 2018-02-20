
//
// THIS HEADER FILE CONTAINS LIBRARIES AND FUNCTION FOR TERPCOPTER MISSION
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
#ifndef WAYPOINTFUNCTION_HPP_
#define WAYPOINTFUNCTION_HPP_

#include <ros/ros.h>
#include <string>
#include <vector>

#include <geometry_msgs/PoseStamped.h>
#include <mavros_msgs/CommandBool.h>
#include <mavros_msgs/SetMode.h>
#include <mavros_msgs/State.h>
#include <nav_msgs/Odometry.h>

#include <tf/tf.h>
#include <tf/transform_broadcaster.h>


#define MISSION_NODE "autonomy"

using namespace std;

class TerpCopterMission {

private:
    // Node handler
    ros::NodeHandle nh;
    ros::NodeHandle priv_nh;

    // Subscriber 
    ros::Subscriber state_sub;
    ros::Subscriber pos_sub;

    // Publishers
    ros::Publisher local_pos_pub;

    // ros::ServiceClient arming_client;
    // ros::ServiceClient set_mode_client;

    // Messages
    mavros_msgs::State current_state;
    //geometry_msgs::PoseStamped terpcopter_pose;
    vector<geometry_msgs::PoseStamped> waypoint_pose;
    nav_msgs::Odometry current_odom;

    // checks
    bool verbal_flag;
    bool init_local_pose_check;
    //bool vision_flag;
    //bool returnFlight;

    // Motion waypoints 
    int waypoint_count;
    
    int num_waypoint;
    vector<double> x_pos;
    vector<double> y_pos;
    vector<double> z_pos;

public: 

    TerpCopterMission();
    // Callbacks
    void state_cb(const mavros_msgs::State::ConstPtr& msg);
    void state_cu(const nav_msgs::Odometry::ConstPtr& msg);
    void init_pose(const geometry_msgs::PoseStamped::ConstPtr& msg);
    void get_waypoints();
    void publish_waypoints();
};

#endif