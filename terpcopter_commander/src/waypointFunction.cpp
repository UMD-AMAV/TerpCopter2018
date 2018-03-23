#include <waypointFunction.h>

using namespace mission;
using namespace std;

// constructor
terpcopterMission::terpcopterMission():
main_state(ST_INIT),
rate(20.0)
{
    // clear all members's value here

}

// state_sub
terpcopterMission::~terpcopterMission(){

}

void terpcopterMission::tercoptermission_main(void){

    // subscribers init
    state_sub = nh.subscribe<mavros_msgs::State>("mavros/state", 10, &terpcopterMission::state_cb, this);
    cur_pos_sub = nh.subscribe<geometry_msgs::PoseStamped>("mavros/local_position/pose", 10, &terpcopterMission::local_pos_cb, this);
    //red_target_pos_sub = nh.subscribe<geometry_msgs::PoseStamped>("redTargetPose", 10, &terpcopterMission::red_target_pos_cb, this); //check this same call back function

    // publishers init
    local_pos_sp_pub = nh.advertise<geometry_msgs::PoseStamped>("mavros/setpoint_position/local", 10);

    // clients init
    land_client = nh.serviceClient<mavros_msgs::CommandTOL>("mavros/cmd/land");
    //targetInertialPose_client = nh.serviceClient<gazebo_msgs::GetModelState>("/red_I_pose");

    //ros::ServiceClient arming_client =_nh.serviceClient<mavros_msgs::CommandBool>("mavros/cmd/arming"); 
    //ros::ServiceClient set_mode_client = _nh.serviceClient<mavros_msgs::SetMode>("mavros/set_mode");

    ROS_INFO("wait for FCU connection");
    wait_connect();

    ROS_INFO("send a few setpoints before switch to OFFBOARD mode");
    cmd_streams();

    // for landing service
    landing_last_request = ros::Time::now();
    //ros::Time last_request = ros::Time::now();

    //mavros_msgs::SetMode offb_set_mode;
    //offb_set_mode.request.custom_mode = "OFFBOARD";

    //mavros_msgs::CommandBool arm_cmd;
    //arm_cmd.request.value = true;

    // state machine
    while(ros::ok()){

		if(!current_state.armed){
			main_state = ST_INIT;
		}

        //  if( _current_state.mode != "OFFBOARD" &&
        //     (ros::Time::now() - last_request > ros::Duration(5.0))){
        //     if( set_mode_client.call(offb_set_mode) &&
        //         offb_set_mode.response.mode_sent){
        //         ROS_INFO("Offboard enabled");
        //     }
        //     last_request = ros::Time::now();
        // } else {
        //     if( !_current_state.armed &&
        //         (ros::Time::now() - last_request > ros::Duration(5.0))){
        //         if( arming_client.call(arm_cmd) &&
        //             arm_cmd.response.success){
        //             ROS_INFO("Vehicle armed");
        //         }
        //         last_request = ros::Time::now();
        //     }
        // }


        state_machine();
        ros::spinOnce();
        rate.sleep();
    }
}

void terpcopterMission::state_machine(void)
{
    /***************** TODO: get values from file ***********************/
    ROS_DEBUG_ONCE("State Machine"); // message will be printed only once
    geometry_msgs::PoseStamped pose_a;
    geometry_msgs::PoseStamped pose_b;
    // geometry_msgs::Point pp;
    //geometry_msgs::Quaternion qq;
    //geometry_msgs::PoseStamped redTarget_pose;

	set_pos_sp(pose_a, 0.0, 0.0, 2.0); //TODO get the waypoints from file
	set_yaw_sp(pose_a, 0.0);

	set_pos_sp(pose_b, 2.5, 1.0, 2.0);
	set_yaw_sp(pose_b, 0.0);

    //redTarget_pose.pose.position.x = 4.0;
    //redTarget_pose.pose.position.y = 2.0;
    //redTarget_pose.pose.position.z = 2.0;

    //int count = 1;

    /****************************************/

    switch(main_state){
        case ST_INIT:
            local_pos_sp_pub.publish(current_local_pos);
            if(current_state.armed && current_state.mode == "OFFBOARD")    // start mission
            {
                main_state = ST_TAKEOFF;
            }
            break;
        case ST_TAKEOFF:
            ROS_DEBUG_ONCE("Takeoff");
            //cout<<"pose :"<< pose_a.pose.position.x<<endl;

            local_pos_sp_pub.publish(pose_a);      // publish display's local position
            ROS_INFO("Current pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,current_local_pos.pose.position.y,
            current_local_pos.pose.position.z);

            ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_a.pose.position.x),
            abs(current_local_pos.pose.position.y - pose_a.pose.position.y),
            abs(current_local_pos.pose.position.z - pose_a.pose.position.z));

            if((abs(current_local_pos.pose.position.x - pose_a.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_a.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_a.pose.position.z) < 0.1))
               {
                    main_state = ST_SEARCH; // get digital number from display
               }
            break;

        case ST_SEARCH:
            ROS_DEBUG_ONCE("Searching");
            local_pos_sp_pub.publish(pose_b);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_b.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_b.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_b.pose.position.z) < 0.1))
               {
                    main_state = ST_REDTARGET;
               }
            break;

        case ST_REDTARGET:
            ROS_DEBUG_ONCE("Target"); // IS at 4,2

            // TODO: call redtarget avg function 
            // get x and y avg values for 20s data
            //publish the first x
            // second time get 20 s data
            // and move unitl the threshold is 10cm 
            // move y unitl the threshold is 10 cm
           //cout<<"Target Position X: "<<red_target_pos.pose.position.x<<endl;
           // units 
            

            // targetInertialPose_client.call(getTargetState);
            // pp = getTargetState.request.pose.position;

            // ROS_INFO("redTareget pose-> X: [%f], Y: [%f], Z: [%f]", pp.x, pp.y, pp.z);

            set_pos_sp(pose_a, 0.0, 0.0, 2.0); //TODO get the waypoints from file
	        set_yaw_sp(pose_a, 0.0);




        //    if((abs(current_local_pos.pose.position.x - redTarget_pose.Pose.Position.X) < 0.1) &&
        //       (abs(current_local_pos.pose.position.y - redTarget_pose.pose.position.y) < 0.1) &&
        //       (abs(current_local_pos.pose.position.z - redTarget_pose.pose.position.z) < 0.1))
        //    {
        //        main_state = ST_LAND;
        //    }
        //    break;

            // local_pos_sp_pub.publish( );      // start sub state machine, here just publish local pos for debug convenience
            // if((abs(current_local_pos.pose.position.x - pose_b.pose.position.x) < 0.1) &&
            //    (abs(current_local_pos.pose.position.y - pose_b.pose.position.y) < 0.1) &&
            //    (abs(current_local_pos.pose.position.z - pose_b.pose.position.z) < 0.1))
            //    {
            //         main_state = ST_LAND;
            //    }
            // break;

        case ST_LAND:
            if(current_state.mode == "OFFBOARD"){
                // used same logic given in sample code for offboard mode
                if(current_state.mode != "AUTO.LAND" &&
                (ros::Time::now() - landing_last_request > ros::Duration(5.0))){
                if(land_client.call(landing_cmd) &&
                    landing_cmd.response.success){
                    ROS_INFO("AUTO LANDING!");
                }
                landing_last_request = ros::Time::now();
                }
            }
            break;
    }
}

// uav state subscriber's callback function
void terpcopterMission::state_cb(const mavros_msgs::State::ConstPtr& msg)
{
    current_state = *msg;
}

// local pos subscriber's callback function
void terpcopterMission::local_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg)
{
    current_local_pos = *msg;
}

// red target pose subscriber callback function
// void terpcopterMission::red_target_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg)
// {
//     red_target_pos = *msg;
// }
// wait for mavros connecting with pixhawk
void terpcopterMission::wait_connect(void)
{
    while(ros::ok() && !current_state.connected){
        ros::spinOnce();
        rate.sleep();
    }
}

// send commands streams to pixhawk before switch to OFFBOARD mode
void terpcopterMission::cmd_streams(void)
{
    // publish current local position
    for(int i = 100; ros::ok() && i > 0; --i){
        local_pos_sp_pub.publish(current_local_pos);
        ros::spinOnce();
        rate.sleep();
    }
}

// set yaw setpoint -- unit: rad
void terpcopterMission::set_yaw_sp(geometry_msgs::PoseStamped &pose, const double yaw)
{
	tf::Quaternion quat_yaw = tf::createQuaternionFromYaw(yaw);
	pose.pose.orientation.x = quat_yaw.x();
	pose.pose.orientation.y = quat_yaw.y();
	pose.pose.orientation.z = quat_yaw.z();
	pose.pose.orientation.w = quat_yaw.w();
}

// set position setpoint -- unit: m
void terpcopterMission::set_pos_sp(geometry_msgs::PoseStamped &pose, const double x, const double y, const double z)
{
	pose.pose.position.x = x;
    pose.pose.position.y = y;
    pose.pose.position.z = z;
}

// update target pose w/r to camera -- unit m
// void terpcopterMission::redTarget_avg_sp(geometry_msgs::PoseStamped &pose_Red,int counter)
// {
//     // get the pose value collect data for 10s and avg and pose.x = x
//     //cout<<"Target Position X: "<<red_target_pos.pose.position.x<<endl;
//      float meanX=0; float sumX =0;

//      // FRAME TRANSFORMATION


//     // while(counter ==1)
//     // {
//     for(int i = 0; i < 100; i++) 
//     {//10 Hz so 10 per 1 s if 10s then 100 messages
//         sumX +=red_target_pos.pose.position.x;
//             //ROS_INFO("sumX: [%f]",sumX);
//     }
//     meanX = sumX/100;
//     ROS_INFO("meanX: [%f]",-meanX);

//     pose_Red.pose.position.x = -meanX; //added minus for coordinate trans.


// }