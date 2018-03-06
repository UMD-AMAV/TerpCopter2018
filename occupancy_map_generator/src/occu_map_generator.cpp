// THIS FILE PERFORMS OCCUPANCY MAP GENERATION FROM LIDAR RANGE DATA USING TF
// AND THE NAV STACK
//
// COPYRIGHT BELONGS TO THE AUTHOR OF THIS CODE
//
// AUTHOR : AUSTIN MAHOWALD
// AFFILIATION : UNIVERSITY OF MARYLAND 
// EMAIL : AMAHOWAL@UMD.EDU
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


///////////////////////////////////////////
//
//  LIBRARIES
//
/////////////////////////////////////////// 

#include <ros/ros.h>
#include <nav_msgs/OccupancyGrid.h>
#include <nav_msgs/MapMetaData.h>
#include <geometry_msgs/Pose.h>

///////////////////////////////////////////
//
//  
//
/////////////////////////////////////////// 

int main( int argc, char** argv )
{
  ros::init(argc, argv, "occu_map_generator");
  ros::NodeHandle n;
  ros::Rate r(1);
  ros::Publisher grid_pub = n.advertise<nav_msgs::OccupancyGrid>("OccupancyGrid", 1);

  //ros::Subscriber origin_pose = n.subscribe<geometry_msgs::Pose>("mavros/local_position/pose", 10, &terpcopterMission::local_pos_cb, this);

  while (ros::ok())
  {
    nav_msgs::OccupancyGrid grid;
    // Set the frame ID and timestamp.  See the TF tutorials for information on these.
    grid.header.frame_id = "/my_frame";
    grid.header.stamp = ros::Time::now();


    //Add grid timestamp here. this will be important for guidance later
    //grid.info.time_map_load_time = timestamp
    grid.info.resolution = 1.0; //float32 meters per cell
    grid.info.width = 10; //uint32
    grid.info.height = 10; //uint32

    grid.data.resize(100,int(0));

    for(int i=0;i<100;i++){
      grid.data.at(i)=i;
    }

    //import odometry here?

    grid.info.origin.position.x = 0.0;
    grid.info.origin.position.y = 0.0;
    grid.info.origin.position.z = 0.0;

    grid.info.origin.orientation.x = 0.0;
    grid.info.origin.orientation.y = 0.0;
    grid.info.origin.orientation.z = 0.0;
    grid.info.origin.orientation.w = 0.0;

    // Publish the grid

    while (grid_pub.getNumSubscribers() < 1)
    {
      if (!ros::ok())
      {
        return 0;
      }
      ROS_WARN_ONCE("Please create a subscriber to the marker");
      sleep(1);
    }
    grid_pub.publish(grid);

    r.sleep();
  }
}