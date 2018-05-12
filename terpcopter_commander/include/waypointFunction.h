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
#include <sensor_msgs/Range.h>

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
	ST_OBSTACLE, //SEARCH FOR OBSTACELS LOGIC
	ST_BOXMOVE, // MOVE TO SEARCH AREA
	ST_SEARCH1, // SEARCH IN DIAMOND PATTERN
	ST_SEARCH2,
	ST_SEARCH3,
	ST_SEARCH4,
	ST_RED,  // IF RED CIRCLE IS RECOGNIZED LAND
	ST_BLACK, // SEARCH AND LOOK FOR BLACK 
	ST_BACK1, // RETURN WAYPOINT 1
	ST_OBSTACLE2, // OBSTACLE LOGIC
	ST_BACK2, // RETURN WAYPOINT 2
	ST_HOME, // SEARCH FOR HOME 
	ST_LAND // LAND 
};


class terpcopterMission {

private:
   // state machine
		 void state_machine(void);

		 // callback functions
		 void state_cb(const mavros_msgs::State::ConstPtr& msg);
		 void local_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg);
		 void red_target_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg);
		 void black_target_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg);
		 void home_target_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg);
		 void waypoints_matlab_cb(const geometry_msgs::PoseArray::ConstPtr& msg); // callback for matlab waypoints
		 void obstacle_cb(const sensor_msgs::Range::ConstPtr& msg);

		 void wait_connect(void);
		 void cmd_streams(void); //hack! send few stepoints to activate offboard mode		

		 void set_yaw_sp(geometry_msgs::PoseStamped &pose, const double yaw); //yaw setpoint
		 void set_pos_sp(geometry_msgs::PoseStamped &pose, const double x, const double y, const double z);	// set position setpoint
		 
	 	 // Subscribers 
		 ros::Subscriber state_sub;			// get pixhawk's arming and status
		 ros::Subscriber cur_pos_sub;		// get pixhawk current local position
		 ros::Subscriber redtarget_Ipos_sub;
		 ros::Subscriber blacktarget_Ipos_sub;
		 ros::Subscriber hometarget_Ipos_sub;
		 ros::Subscriber waypoints_sub;
		 ros::Subscriber obstacle_sub;
		 
		 // Publishers
		 ros::Publisher local_pos_sp_pub;		// pusblish local position setpoint to pixhawk
		 ros::Publisher state_pub;


		 // Services
		 ros::ServiceClient land_client;		// land command 
		 mavros_msgs::CommandTOL landing_cmd;
		 ros::Time landing_last_request;

public: 

        terpcopterMission(); //constructor 
        ~terpcopterMission(); //deconstructor 

        void tercoptermission_main(void);							// entry point

       	geometry_msgs::PoseStamped current_local_pos; // current local postion
		geometry_msgs::PoseStamped red_target_pos; //current red target pose
		geometry_msgs::PoseStamped black_target_pos;
		geometry_msgs::PoseStamped home_target_pos;
		mavros_msgs::State current_state;			// current arm status and mode
		sensor_msgs::Range obstacle_range;

        geometry_msgs::PoseStamped local_pos_sp; // actual local pos sent 
		geometry_msgs::PoseArray waypoints_matlab;
		std_msgs::String state; //state machine state matlab
		geometry_msgs::PoseStamped pose_c; 
		geometry_msgs::PoseStamped pose_r;
		geometry_msgs::PoseStamped pose_b;
		geometry_msgs::PoseStamped pose_h;		

        uint8_t main_state;			// main state for state machine
        ros::NodeHandle nh;
        ros::Rate rate;
    };

}
