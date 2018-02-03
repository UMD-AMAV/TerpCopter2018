
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
#include <offbFunction.h>


///////////////////////////////////////////
//
//	MAIN FUNCTION
//
///////////////////////////////////////////


int main(int argc, char **argv){
    ros::init(argc, argv, MISSION_NODE);

    // Object
    TerpCopterMission mission;

    ros::Subscriber state_sub = 
        mission.nh.subscribe<mavros_msgs::State>
            ("mavros/state", 10, &TerpCopterMission::state_cb,&mission);

    ros::Subscriber pos_sub = 
        mission.nh.subscribe<nav_msgs::Odometry>
            ("mavros/local_position/odom", 40, &TerpCopterMission::state_cu,&mission);

    mission.local_pos_pub = 
        mission.nh.advertise<geometry_msgs::PoseStamped>
            ("mavros/setpoint_position/local", 40);

    ros::ServiceClient arming_client = 
        mission.nh.serviceClient<mavros_msgs::CommandBool>
            ("mavros/cmd/arming");
    ros::ServiceClient set_mode_client = 
        mission.nh.serviceClient<mavros_msgs::SetMode>
            ("mavros/set_mode");

    //the setpoint publishing rate MUST be faster than 2Hz
    ros::Rate rate(50.0);

    // wait for FCU connection
    while(ros::ok() && !mission.current_state.connected){
        ros::spinOnce();
        rate.sleep();
    }

    mission.hover(2.0);
    //send a few setpoints before starting
    for(int i = 100; ros::ok() && i > 0; --i){
        mission.local_pos_pub.publish(mission.pose);
        ros::spinOnce();
        rate.sleep();
    }

    mavros_msgs::SetMode offb_set_mode;
    offb_set_mode.request.custom_mode = "OFFBOARD";

    mavros_msgs::CommandBool arm_cmd;
    arm_cmd.request.value = true;

    ros::Time last_request = ros::Time::now();

    while(ros::ok()){
        if( mission.current_state.mode != "OFFBOARD" &&
            (ros::Time::now() - last_request > ros::Duration(5.0))){
            if( set_mode_client.call(offb_set_mode) &&
                offb_set_mode.response.mode_sent){
                ROS_INFO("Offboard enabled");
            }
            last_request = ros::Time::now();
        } else {
            if( !mission.current_state.armed &&
                (ros::Time::now() - last_request > ros::Duration(5.0))){
                if( arming_client.call(arm_cmd) &&
                    arm_cmd.response.success){
                    ROS_INFO("Vehicle armed");
                }
                last_request = ros::Time::now();
            }
        }

        // setpoint 1= (12,2.1,2)
        // setpoint 2= (yaw (rot about z, +/- 120))
        // setpoint 3= ()

        //HOVER 
        mission.hover(2.0);

         // TODO: LOOP OVER ALL THE WAYPOINTS FROM A .TXT FILE AND RUN THEM ONE BY ONE
         // CREATE A FUNCTION BOOL REACHED 

        //move to waypoints
        if (mission.current_odom.pose.pose.position.z >= 0.95 * mission.pose.pose.position.z ){
            ROS_INFO("Position-> z: [%f]",mission.current_odom.pose.pose.position.z);
                mission.yaw(60,2.0);
        }

        if(mission.current_odom.pose.pose.orientation.x >=0.95*mission.pose.pose.orientation.x && 
            mission.current_odom.pose.pose.orientation.y >=0.95*mission.pose.pose.orientation.y && 
            mission.current_odom.pose.pose.orientation.z >=0.95*mission.pose.pose.orientation.z &&
            mission.current_odom.pose.pose.orientation.w >=0.95*mission.pose.pose.orientation.w ){
                ROS_INFO("hover");
                mission.hover(2.0);

        }

        ros::spinOnce();
        rate.sleep();
    }

    return 0;
}

void TerpCopterMission::state_cb(const mavros_msgs::State::ConstPtr& msg){
    current_state = *msg;
}

void TerpCopterMission::state_cu (const nav_msgs::Odometry::ConstPtr& msgS){
    //ROS_INFO("Position x: [%f], y: [%f], z: [%f]", msgP->pose.pose.position.x,msgP->pose.pose.position.y, msgP->pose.pose.position.z);
    current_odom = *msgS;
}

void TerpCopterMission::hover(float z){
    //ROS_INFO("Hovering");
    pose.pose.position.x = 0.0;
    pose.pose.position.y = 0.0;
    pose.pose.position.z = z;

    pose.pose.orientation.x = 0.0;
    pose.pose.orientation.y = 0.0;
    pose.pose.orientation.z = 0.0;
    pose.pose.orientation.w = 0.0;

    local_pos_pub.publish(pose);
}

void TerpCopterMission::move(float x, float y, float z){
    ROS_INFO("Moving");
    
    pose.pose.position.x = x;
    pose.pose.position.y = y;
    pose.pose.position.z = abs(z);

    //double t0 = ros::Time::now().toSec();
    double current_distance = 0.0;

    do{
        local_pos_pub.publish(pose);
        //double t1 = ros::Time::now().toSec();
        current_distance = current_odom.pose.pose.position.x;
        //ROS_INFO("Position-> x: [%f]",current_odom.pose.pose.position.x);
    }while(current_distance >= 0.95 * pose.pose.position.x);

}

void TerpCopterMission::yaw (float yawMsg, float z){
//TO DO: check the quaternion conventions
    ROS_INFO("Yaw");

    pose.pose.position.x = 0.0;
    pose.pose.position.y = 0.0;
    pose.pose.position.z = z;

    tf::Quaternion q= tf::createQuaternionFromYaw(yawMsg*0.0174532925);
    pose.pose.orientation.x = q[0];
    pose.pose.orientation.y = q[1];
    pose.pose.orientation.z = q[2];
    pose.pose.orientation.w = q[3];
            
    local_pos_pub.publish(pose);
}

// bool TerpCopterMission::isReachedPos (){
//     retun (current_odom.pose.pose.position.z >= 0.95 * pose.pose.position.z);
// }

