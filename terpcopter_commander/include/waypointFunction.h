//
// THIS HEADER FILE CONTAINS LIBRARIES AND FUNCTION FOR TERPCOPTER MISSION
//
// COPYRIGHT BELONGS TO THE AUTHOR OF THIS CODE
//
// AUTHOR : SAIMOULI KATRAGADDA
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
#include <ros/console.h>
#include <string>
#include <vector>
#include <iostream>

#include <geometry_msgs/PoseStamped.h>
#include <geometry_msgs/PoseArray.h>
#include <geometry_msgs/Pose.h>
#include <std_msgs/String.h>
#include <mavros_msgs/CommandBool.h>
#include <mavros_msgs/CommandTOL.h>
#include <mavros_msgs/SetMode.h>
#include <mavros_msgs/State.h>
#include <nav_msgs/Odometry.h>


#include "gazebo_msgs/GetModelState.h"
#include "gazebo_msgs/SetModelState.h"

#include <tf/tf.h>
#include <tf/transform_broadcaster.h>


#define MISSION_NODE "autonomy"

///////////////////////////////////////////
//
//	CLASS
//
/////////////////////////////////////////// 
namespace mission{

enum MAIN_STAT{
	ST_INIT =0,
	ST_TAKEOFF,
	ST_MOVE1,
	// ST_OBSTACLE,
	// ST_SEARCHBOX,
	// ST_SEARCH,
	// ST_RED,
	// ST_SEARCH2,
	// ST_BLACK,
	// ST_RETURN1,
	// ST_HOME,
	ST_LAND
};


class terpcopterMission {

private:
   // state machine
		 void state_machine(void);

		 // callback functions
		 void state_cb(const mavros_msgs::State::ConstPtr& msg);
		 void local_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg);
		 void red_target_pos_cb(const geometry_msgs::Pose::ConstPtr& msg);
		 void waypoints_matlab_cb(const geometry_msgs::PoseArray::ConstPtr& msg); // callback for matlab waypoints 

		 void wait_connect(void);

		 void cmd_streams(void); //hack! send few stepoints to activate offboard mode		

		 void set_yaw_sp(geometry_msgs::PoseStamped &pose, const double yaw); //yaw setpoint
		 void set_pos_sp(geometry_msgs::PoseStamped &pose, const double x, const double y, const double z);	// set position setpoint
		 
	 	 // Subscribers 
		 ros::Subscriber state_sub;			// get pixhawk's arming and status
		 ros::Subscriber cur_pos_sub;		// get pixhawk current local position
		 //ros::Subscriber redtarget_Ipos_sub;
		 ros::Subscriber waypoints_sub;
		 
		 // Publishers
		 ros::Publisher local_pos_sp_pub;		// pusblish local position setpoint to pixhawk
		 ros::Publisher state_pub;


		 // Services
		 ros::ServiceClient land_client;		// land command 
		 //ros::ServiceClient targetInertialPose_client;

		 mavros_msgs::CommandTOL landing_cmd;
		 //terpcopter_comm::DetectTargetPose target_pose;


		 ros::Time landing_last_request;

		 int count2; int trial;

public: 

        terpcopterMission(); //constructor 
        ~terpcopterMission(); //deconstructor 

        void tercoptermission_main(void);							// entry point

        geometry_msgs::PoseStamped current_local_pos; // current local postion
		//geometry_msgs::Pose red_target_pos; //current red target pose
        mavros_msgs::State current_state;			// current arm status and mode

        geometry_msgs::PoseStamped local_pos_sp; // actual local pos sent 
		geometry_msgs::PoseArray waypoints_matlab;
		std_msgs::String state; //state machine state matlab
		geometry_msgs::PoseStamped pose_c; 
		

        uint8_t main_state;			// main state for state machine
        ros::NodeHandle nh;
        ros::Rate rate;
    };

}