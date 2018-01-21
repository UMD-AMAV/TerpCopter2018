// This program publishes command messages for the servo sweep

#include <ros/ros.h>
#include <std_msgs/UInt16.h> 
#include <stdlib.h> 

int main(int argc, char **argv) {

	// Initiate the ROS system and become a node
	ros::init(argc, argv, "sweep_ctrl");
	ros::NodeHandle nh;

	// Create a publisher object
	ros::Publisher pub_sweep = nh.advertise<std_msgs::UInt16>(
		"servo1", 1000);
		
	ros::Duration(4).sleep();

	// Loop at 2Hz until the node is shut down
	ros::Rate rate(0.17); // repeat every 6 seconds, 1 sweep = 6 sec
	while(ros::ok()) {
		// Create and fill in the message. The other four fields,
		// which are ignored by turtlesim, default to 0
		std_msgs::UInt16 msg;
		msg.data = 10;

		// Publish the message
		pub_sweep.publish(msg);

		// Send a message to rosout with the details
		ROS_INFO_STREAM("Sending sweep command...");

		// Wait until it's time for another iteration
		rate.sleep();
	}
}
