// Working Code for Yaw and traveling from point A to B

#include <ros/ros.h>
#include <geometry_msgs/PoseStamped.h>
#include <mavros_msgs/CommandBool.h>
#include <mavros_msgs/SetMode.h>
#include <mavros_msgs/State.h>
#include <mavros_msgs/PositionTarget.h>
#include <math.h>
#include <iostream>
#include <stdio.h>
#include <tf/tf.h>
#include <tf/transform_broadcaster.h>

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
int hover_return = 0;
int yaw_return = 0;
double count=0.0;
double wn = 1.0; // Angular velocity

class TerpcopterMission
{ 
public:
    mavros_msgs::State current_state;
    geometry_msgs::PoseStamped actual_current_state;
    geometry_msgs::PoseStamped pose;
    ros::NodeHandle nh;
    ros::Publisher local_pos_pub;
    
    void state_cb(const mavros_msgs::State::ConstPtr& msg);
    void actual_state_cb(const geometry_msgs::PoseStamped::ConstPtr& data);
    int hover(float);
    int yaw(float);
    void traverse(float,float, float);
    
};


void TerpcopterMission::state_cb(const mavros_msgs::State::ConstPtr& msg){
    current_state = *msg;
}

void TerpcopterMission::actual_state_cb(const geometry_msgs::PoseStamped::ConstPtr& data)
{
actual_current_state = *data;
}

int TerpcopterMission::hover(float z)
{   printf(" Entered Hover Function. Z = %f\n",z);
    pose.pose.position.x = 0;
    pose.pose.position.y = 0;
    pose.pose.position.z = z;
    pose.pose.orientation.x = 0.0;
    pose.pose.orientation.y = 0.0;
    pose.pose.orientation.z = 0.0;
    pose.pose.orientation.w = 0.0;

    local_pos_pub.publish(pose);
    if (actual_current_state.pose.position.z >=0.95*z)
        return 1;

}

int TerpcopterMission::yaw(float theta)
{
    //Yaw 
        tf::Quaternion q = tf::createQuaternionFromYaw(theta);
        pose.pose.orientation.x = q[0];
        pose.pose.orientation.y = q[1];
        pose.pose.orientation.z = q[2];
        pose.pose.orientation.w = q[3];
                
    
        local_pos_pub.publish(pose);
        if (pose.pose.orientation.x  >= 0.95*q[0] && //pose.pose.orientation.x  <= 1.05*q[0] &&
            pose.pose.orientation.y  >= 0.95*q[1] && //pose.pose.orientation.y  <= 1.05*q[1] &&
            pose.pose.orientation.z  >= 0.95*q[2] && //pose.pose.orientation.z  <= 1.05*q[2] &&
            pose.pose.orientation.w  >= 0.95*q[3] )//&& pose.pose.orientation.w  <= 1.05*q[3])
            
            return 1;
}

void TerpcopterMission::traverse(float r, float theta, float z)
{
    

        pose.pose.position.x = r*sin(theta);
        pose.pose.position.y = r*cos(theta);
        pose.pose.position.z = z;  // Altitude at which the quad flies
        
        local_pos_pub.publish(pose);
        
}


int main(int argc, char **argv)
{   

    ros::init(argc, argv, "offb_node_3");
    
    TerpcopterMission mission;
    ros::Subscriber state_sub = mission.nh.subscribe<mavros_msgs::State>
            ("mavros/state", 10, &TerpcopterMission::state_cb, &mission);
    ros::Subscriber actual_state_sub = mission.nh.subscribe<geometry_msgs::PoseStamped>
            ("/mavros/local_position/pose", 10, &TerpcopterMission::actual_state_cb, &mission);        
    mission.local_pos_pub = mission.nh.advertise<geometry_msgs::PoseStamped>
            ("mavros/setpoint_position/local", 10);       
    ros::ServiceClient arming_client = mission.nh.serviceClient<mavros_msgs::CommandBool>
            ("mavros/cmd/arming");
    ros::ServiceClient set_mode_client = mission.nh.serviceClient<mavros_msgs::SetMode>
            ("mavros/set_mode");
    
    
    //the setpoint publishing rate MUST be faster than 2Hz

    ros::Rate rate(20.0);

    // wait for FCU connection
    while(ros::ok() && mission.current_state.connected){
        
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

    printf("Enter Point B coordinates\n");
    scanf("%2f %2f", &x_B,&y_B);


    mavros_msgs::SetMode offb_set_mode;
    offb_set_mode.request.custom_mode = "OFFBOARD";

    mavros_msgs::CommandBool arm_cmd;
    arm_cmd.request.value = true;
	
    ros::Time last_request = ros::Time::now();

    while(ros::ok()){
     //printf("Entered While loop\n");
      if( mission.current_state.mode != "OFFBOARD" &&
            (ros::Time::now() - last_request > ros::Duration(5.0))){
        printf("Inside if\n");
            if( set_mode_client.call(offb_set_mode) &&
                offb_set_mode.response.mode_sent){
                ROS_INFO("Offboard enabled");
                
                
            }
            last_request = ros::Time::now();
            // prinf and scanf work when placed here
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
// Need to change this part 
    x_A = 0.0;
    y_A = 0.0;
    diff_X = x_B - x_A;
    diff_Y = y_B - y_A;
    expr = pow(diff_X,2) + pow(diff_Y,2);
    
    //calculating distance and yaw angle
    r = sqrt(expr);
    theta = atan(diff_Y/diff_X);

    hover_return =  mission.hover(2.0);
    if (hover_return == 1)
     { yaw_return = mission.yaw(theta);
        if (yaw_return == 1)
        {   //ros::Duration(0.05).sleep();
            mission.traverse(r, theta, 2.0);
        }
        
      }  

        ros::spinOnce();
        rate.sleep();
    }

    return 0;
}
