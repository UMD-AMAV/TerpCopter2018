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

    // publishers init
    local_pos_sp_pub = nh.advertise<geometry_msgs::PoseStamped>("mavros/setpoint_position/local", 10);

    // services init
    land_client = nh.serviceClient<mavros_msgs::CommandTOL>("mavros/cmd/land");
    //ros::ServiceClient arming_client =_nh.serviceClient<mavros_msgs::CommandBool>("mavros/cmd/arming"); 
    //ros::ServiceClient set_mode_client = _nh.serviceClient<mavros_msgs::SetMode>("mavros/set_mode");

    cout<<"wait for FCU connection"<<endl;
    wait_connect();

    cout<<"send a few setpoints before switch to OFFBOARD mode"<<endl;
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
    cout<<"state machine"<<endl;
    geometry_msgs::PoseStamped pose_a;
    geometry_msgs::PoseStamped pose_b;
    geometry_msgs::PoseStamped pose_c;
    geometry_msgs::PoseStamped pose_d;
    geometry_msgs::PoseStamped pose_e;
    geometry_msgs::PoseStamped pose_f;
    geometry_msgs::PoseStamped pose_g;
    geometry_msgs::PoseStamped pose_h;
    geometry_msgs::PoseStamped pose_i;

	set_pos_sp(pose_a, 0.0, 0.0, 2.0); //TODO get the waypoints from file
	set_yaw_sp(pose_a, 0);

	set_pos_sp(pose_b, 5.0, 4.0, 2.0);
	set_yaw_sp(pose_b, 0);

    set_pos_sp(pose_c, 11.5, 6.5, 2.0);
    set_yaw_sp(pose_c, 0);

    set_pos_sp(pose_d, 11.5, 6.5, 0.1);
    set_yaw_sp(pose_d, 0);

    set_pos_sp(pose_e, 11.5, 6.5, 2.0);
    set_yaw_sp(pose_e, 0);

    set_pos_sp(pose_f, 16.5, 2.0, 2.0);
    set_yaw_sp(pose_f, 0);

    set_pos_sp(pose_g, 16.5, 2.0, 0.2);
    set_yaw_sp(pose_g, 0);

    set_pos_sp(pose_h, 16.5, 2.0, 2.0);
    set_yaw_sp(pose_h, 0);

    set_pos_sp(pose_i, 0.0, 0.0, 2.0);
    set_yaw_sp(pose_i, 0);
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
            cout<<"Takeoff"<<endl;
            //cout<<"pose :"<< pose_a.pose.position.x<<endl;

            local_pos_sp_pub.publish(pose_a);      // publish display's local position
            if((abs(current_local_pos.pose.position.x - pose_a.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_a.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_a.pose.position.z) < 0.1))
               {
                    main_state = ST_MOVE1; // get digital number from display
               }
            break;
        case ST_MOVE1:
            local_pos_sp_pub.publish(pose_b);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_b.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_b.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_b.pose.position.z) < 0.1))
               {
                    main_state = ST_MOVE2;
               }
            break;
        case ST_MOVE2:
            local_pos_sp_pub.publish(pose_c);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {
                    main_state = ST_MOVE3;
               }
            break;
        case ST_MOVE3:
            local_pos_sp_pub.publish(pose_d);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_d.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_d.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_d.pose.position.z) < 0.1))
               {
                    main_state = ST_MOVE4;
               }
            break;    
        case ST_MOVE4:
            local_pos_sp_pub.publish(pose_e);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_e.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_e.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_e.pose.position.z) < 0.1))
               {
                    main_state = ST_MOVE5;
               }
            break;  
        case ST_MOVE5:
            local_pos_sp_pub.publish(pose_f);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_f.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_f.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_f.pose.position.z) < 0.1))
               {
                    main_state = ST_MOVE6;
               }
            break;  
        case ST_MOVE6:
            local_pos_sp_pub.publish(pose_g);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_g.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_g.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_g.pose.position.z) < 0.1))
               {
                    main_state = ST_MOVE7;
               }
            break;    
        case ST_MOVE7:
            local_pos_sp_pub.publish(pose_h);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_h.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_h.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_h.pose.position.z) < 0.1))
               {
                    main_state = ST_MOVE8;
               }
            break;   
        case ST_MOVE8:
            local_pos_sp_pub.publish(pose_i);      // start sub state machine, here just publish local pos for debug convenience
            if((abs(current_local_pos.pose.position.x - pose_i.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_i.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_i.pose.position.z) < 0.1))
               {
                    main_state = ST_LAND;
               }
            break;         
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
