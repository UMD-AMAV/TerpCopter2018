
//
// THIS FILE CONTAINS A SAMPLE MISSION IMPLEMENTATION THROUGH
// MAVROS SERVICES AND RELIES ON LPE ESTIMATOR
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
#include "waypointFunction.hpp"

///////////////////////////////////////////
//
//	MAIN FUNCTION
//
///////////////////////////////////////////

TerpCopterMission::TerpCopterMission():
verbal_flag(false), init_local_pose_check(true), priv_nh("~"){

    priv_nh.getParam("verbal_flag", verbal_flag);

    // Subscriber
    state_sub = nh.subscribe<mavros_msgs::State>
            ("mavros/state", 10, &TerpCopterMission::state_cb, this);

    pos_sub = nh.subscribe<nav_msgs::Odometry>
            ("mavros/local_position/odom", 30, &TerpCopterMission::state_cu, this);

    // TODO: vision circle node up

    // Pulisher
    local_pos_pub = 
        nh.advertise<geometry_msgs::PoseStamped>
            ("mavros/setpoint_position/local", 30);

    get_waypoints();
}

void TerpCopterMission::state_cb(const mavros_msgs::State::ConstPtr& msg){
    current_state = *msg;
}

void TerpCopterMission::state_cu (const nav_msgs::Odometry::ConstPtr& msg){
    //ROS_INFO("Position x: [%f], y: [%f], z: [%f]", msgP->pose.pose.position.x,msgP->pose.pose.position.y, msgP->pose.pose.position.z);
    current_odom = *msg;
}

void TerpCopterMission::get_waypoints() {
    if (ros::param::get("terpcopter_commander/num_waypoint", num_waypoint)) {}
    else {
        ROS_WARN("Didn't find num_waypoint");
    }
    if (ros::param::get("terpcopter_commander/x_pos", x_pos)) {}
    else {
        ROS_WARN("Didn't find x_pos");
    }
    if (ros::param::get("terpcopter_commander/y_pos", y_pos)) {}
    else {
        ROS_WARN("Didn't find y_pos");
    }
    if (ros::param::get("terpcopter_commander/z_pos", z_pos)) {}
    else {
        ROS_WARN("Didn't find z_pos");
    }
}

void TerpCopterMission::init_pose (const geometry_msgs::PoseStamped::ConstPtr& msg){
    if (init_local_pose_check) {
        for(int i = 0; i < num_waypoint; i++){
            geometry_msgs::PoseStamped temp_target_pose;

            temp_target_pose.pose.position.x = msg->pose.position.x + x_pos[i];
            temp_target_pose.pose.position.y = msg->pose.position.y + y_pos[i];
            temp_target_pose.pose.position.z = msg->pose.position.z + z_pos[i];

            waypoint_pose.push_back(temp_target_pose);
        }

        init_local_pose_check = false;
    }

    publish_waypoints();

    ros::Rate rate(50.0);
    rate.sleep();

}
void TerpCopterMission::publish_waypoints(){

    if (!init_local_pose_check) {
        local_pos_pub.publish(waypoint_pose[waypoint_count]);
        if (verbal_flag) {
            double dist = sqrt(
                (current_odom.pose.pose.position.x-waypoint_pose[waypoint_count].pose.position.x)* 
                (current_odom.pose.pose.position.x-waypoint_pose[waypoint_count].pose.position.x) + 
                (current_odom.pose.pose.position.y-waypoint_pose[waypoint_count].pose.position.y)* 
                (current_odom.pose.pose.position.y-waypoint_pose[waypoint_count].pose.position.y) + 
                (current_odom.pose.pose.position.z-waypoint_pose[waypoint_count].pose.position.z)* 
                (current_odom.pose.pose.position.z-waypoint_pose[waypoint_count].pose.position.z)); 
            ROS_INFO("distance: %.2f", dist);

        // if(vision_flag){
                // wait a min observe take the mode
                // align the yaw angle 
                // GET hypotenus move x and y accordingly 
                // P controller for x and y
        // }

        }
        
        if (abs(current_odom.pose.pose.position.x - waypoint_pose[waypoint_count].pose.position.x) < 0.5 && 
            abs(current_odom.pose.pose.position.y - waypoint_pose[waypoint_count].pose.position.y) < 0.5 &&
            abs(current_odom.pose.pose.position.z - waypoint_pose[waypoint_count].pose.position.z) < 0.5) {

            waypoint_count += 1;

            if (waypoint_count >= num_waypoint) {
                waypoint_count = waypoint_count - 1;
            }

            // ROS_INFO("m_waypoint_count = %d, cur_pos = (%.2f, %.2f, %.2f), next_pos = (%.2f, %.2f, %.2f)", m_waypoint_count, 
            //     m_current_pose.pose.position.x, m_current_pose.pose.position.y, m_current_pose.pose.position.z, 
            //     m_waypoint_pose[m_waypoint_count].pose.position.x, m_waypoint_pose[m_waypoint_count].pose.position.y, m_waypoint_pose[m_waypoint_count].pose.position.z);
        }
    }

}


int main(int argc, char **argv){
    ros::init(argc, argv, MISSION_NODE);

    // // Object
    TerpCopterMission mission;

    ros::spin();
    return 0;
}