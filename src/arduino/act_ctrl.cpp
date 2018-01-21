// This program publishes command messages for the servo actuator

#include <ros/ros.h>
#include <std_msgs/UInt16.h> 
#include <stdlib.h> 

int main(int argc, char **argv) {

	// Initiate the ROS system and become a node
	ros::init(argc, argv, "act_ctrl");
	ros::NodeHandle nh;

	// Create a publisher object
	ros::Publisher pub_act = nh.advertise<std_msgs::UInt16>(
		"servo2", 1000);
		
	ros::Duration(3).sleep();

	// Loop at 2Hz until the node is shut down
	ros::Rate rate(0.167); // repeat every 6 seconds
	while(ros::ok()) {
		// Create and fill in the message. The other four fields,
		// which are ignored by turtlesim, default to 0
		std_msgs::UInt16 msg;
		msg.data = 20;

		// Publish the message
		pub_act.publish(msg);

		ros::Duration(1).sleep();

		msg.data = 120;

		pub_act.publish(msg);

		// Send a message to rosout with the details
		ROS_INFO_STREAM("Sending act command...");

		// Wait until it's time for another iteration
		rate.sleep();
	}
}

