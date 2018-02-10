



#include <ros/ros.h>
#include <geometry_msgs/PoseStamped.h>
#include <mavros_msgs/CommandBool.h>
#include <mavros_msgs/SetMode.h>
#include <mavros_msgs/State.h>
#include <mavros_msgs/PositionTarget.h>
#include <math.h>
#include <iostream>
#include <stdio.h>

double r = 3.0;
double expr = 0.0;
double diff_X = 0.0;
double diff_Y = 0.0;
float x_A;
float x_B;
float y_A;
float y_B;
float yaw;
double theta;
double count=0.0;
double wn = 1.0; // Angular velocity

mavros_msgs::State current_state;
void state_cb(const mavros_msgs::State::ConstPtr& msg){
    current_state = *msg;
}

int main(int argc, char **argv)
{
    ros::init(argc, argv, "offb_node_3");
    ros::NodeHandle nh;

    ros::Subscriber state_sub = nh.subscribe<mavros_msgs::State>
            ("mavros/state", 10, state_cb);
    ros::Publisher local_pos_pub = nh.advertise<geometry_msgs::PoseStamped>
            ("mavros/setpoint_position/local", 10);
    ros::Publisher local_yaw_pub = nh.advertise<mavros_msgs::PositionTarget>
            ("mavros/setpoint_raw/local", 10);        
    ros::ServiceClient arming_client = nh.serviceClient<mavros_msgs::CommandBool>
            ("mavros/cmd/arming");
    ros::ServiceClient set_mode_client = nh.serviceClient<mavros_msgs::SetMode>
            ("mavros/set_mode");
    //the setpoint publishing rate MUST be faster than 2Hz
    ros::Rate rate(20.0);

    // wait for FCU connection
    while(ros::ok() && current_state.connected){
        
        ros::spinOnce();
        rate.sleep();
    }

    geometry_msgs::PoseStamped pose;
    pose.pose.position.x = 0;
    pose.pose.position.y = 0;
    pose.pose.position.z = 2;

    //send a few setpoints before starting
    for(int i = 100; ros::ok() && i > 0; --i){
        local_pos_pub.publish(pose);
        ros::spinOnce();
        rate.sleep();
    }

    mavros_msgs::SetMode offb_set_mode;
    offb_set_mode.request.custom_mode = "OFFBOARD";

    mavros_msgs::CommandBool arm_cmd;
    arm_cmd.request.value = true;
	
    ros::Time last_request = ros::Time::now();
    
    mavros_msgs::PositionTarget moveMsg;
    moveMsg.coordinate_frame = mavros_msgs::PositionTarget::
                                                FRAME_BODY_OFFSET_NED;
    moveMsg.type_mask =mavros_msgs::PositionTarget::IGNORE_AFX | 
                                     mavros_msgs::PositionTarget::IGNORE_AFY | 
                                     mavros_msgs::PositionTarget::IGNORE_AFZ |
                                     mavros_msgs::PositionTarget::IGNORE_VX  | 
                                     mavros_msgs::PositionTarget::IGNORE_VY  | 
                                     mavros_msgs::PositionTarget::IGNORE_VZ;


    printf("Enter Point B coordinates\n");
    scanf("%2f %2f", &x_B,&y_B);


    while(ros::ok()){
     
      if( current_state.mode != "OFFBOARD" &&
            (ros::Time::now() - last_request > ros::Duration(5.0))){
            if( set_mode_client.call(offb_set_mode) &&
                offb_set_mode.response.mode_sent){
                ROS_INFO("Offboard enabled");
                // Printf and scanf work when placed here
                
            }
            last_request = ros::Time::now();
            // prinf and scanf work when placed here
        } else {
            if( !current_state.armed &&
                (ros::Time::now() - last_request > ros::Duration(5.0))){
                if( arming_client.call(arm_cmd) &&
                    arm_cmd.response.success){
                    ROS_INFO("Vehicle armed");

                }
                last_request = ros::Time::now();
            }
        }   
// Need to change this part 
    
    x_A = 0.0;
    y_A = 0.0;
    diff_X = x_B - x_A;
    diff_Y = y_B - y_A;
    expr = pow(diff_X,2) + pow(diff_Y,2);
    
    r = sqrt(expr);
    theta = atan(diff_Y/diff_X);
    //printf("%.2f\n",theta);
        moveMsg.header.stamp = ros::Time::now();
        moveMsg.position.x = r*sin(theta);
        moveMsg.position.y = r*cos(theta);
        moveMsg.position.z = 2;
        moveMsg.yaw = -theta;
        moveMsg.yaw_rate = 0.1; 
        //pose.pose.position.x = r*sin(theta);
        //pose.pose.position.y = r*cos(theta);
        //pose.pose.position.z = 2;  // Altitude at which the quad flies

                
        local_yaw_pub.publish(moveMsg);
        //local_pos_pub.publish(pose);
        ros::spinOnce();
        rate.sleep();
    }

    return 0;
}
