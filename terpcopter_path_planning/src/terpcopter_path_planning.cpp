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
#include <pathPlanning.h>

using namespace std;

nav_msgs::OccupancyGrid occu_grid;

///////////////////////////////////////////
//

void
occu_cb(const nav_msgs::OccupancyGrid::ConstPtr& msg)
{
    occu_grid = *msg;
}

//  
//
/////////////////////////////////////////// 

int main( int argc, char** argv )
{
  ros::init(argc, argv, "terpcopter_path_planning");
  ros::NodeHandle n;
  ros::Rate r(1);
  ros::Publisher grid_pub = n.advertise<nav_msgs::OccupancyGrid>("OccupancyGrid_AVIZ", 1);

  ros::Subscriber occu_sub = n.subscribe<nav_msgs::OccupancyGrid>("OccupancyGrid", 1, &occu_cb);

  int arena_width = occu_grid.info.width;
  int arena_height = occu_grid.info.height;
 
  vector<int> map;
  map.resize(arena_height*arena_width,int(0));

  pathPlanning plan(arena_height,arena_width,20,60);
  vector<pathPlanning::node> closedList;
  vector<pathPlanning::node> waypoints;

  for(int i=0;i<(arena_width*arena_height);i++){
  	map.at(i) = occu_grid.data.at(i);
  }

  clock_t start;
  double duration;
  start = clock();
                
  plan.aStarPlan(10,10,closedList,map);
  plan.reverseSearch(closedList,waypoints);

  duration = ( std::clock() - start ) / (double) CLOCKS_PER_SEC;

  cout<<"\n\nProgram has taken "<< duration <<" seconds to run"<<'\n';

  //grid_pub.publish(grid);

  cout<<"Program has Completed"<<endl;

  r.sleep();
}
  //ros::Subscriber origin_pose = n.subscribe<geometry_msgs::Pose>("mavros/local_position/pose", 10, &terpcopterMission::local_pos_cb, this);

//    <!--launch-prefix="gdb -ex run --args" /-->