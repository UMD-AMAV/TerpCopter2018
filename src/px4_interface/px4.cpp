// This program publishes command messages for the servo actuator

#include <ros/ros.h>
#include <std_msgs/UInt16.h> 
#include <stdlib.h> 

int main(int argc, char **argv) {

	// Initiate the ROS system and become a node
	ros::init(argc, argv, "px4");
	ros::NodeHandle nh;

	// Create a publisher object
	ros::Publisher pub_health = nh.advertise<std_msgs::UInt16>(
		"px4_health", 1000);

	// Loop at 2Hz until the node is shut down
	ros::Rate rate(2);
	while(ros::ok()) {
		// Create and fill in the message. The other four fields,
		// which are ignored by turtlesim, default to 0
		std_msgs::UInt16 msg;
		msg.data = 20;

		// Publish the message
		pub_health.publish(msg);

		// Send a message to rosout with the details
		ROS_INFO_STREAM("PX4 interface is running");

		// Wait until it's time for another iteration
		rate.sleep();
	}
}

