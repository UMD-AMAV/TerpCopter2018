//
// THIS FILE PERFORMS AUTONOMOUS WAYPOINT NAVIGATION USING MAVROS
// RUN OFFBOARD MODE AND ARM THE VECHILE USING ROSRUN MAVROS
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
#include <waypointFunction.h>

using namespace mission;
using namespace std;


int main(int argc, char **argv){
    ros::init(argc, argv, "autonomy");

    //set logger level
    if (ros::console::set_logger_level(ROSCONSOLE_DEFAULT_NAME,
        ros::console::levels::Debug))
    ros::console::notifyLoggerLevelsChanged();

    terpcopterMission mis;
    mis.tercoptermission_main();
    return 0;
}