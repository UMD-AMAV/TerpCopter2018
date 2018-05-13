#include <waypointFunction.h>

using namespace mission;
using namespace std;

// GLOBAL 
int wp_received = 0;
int red_flag = 0; int black_flag = 0;
int home_flag = 0; 

int counter1; int trial1;
int counter2; int trial2;
int counter3; int trial3;

int increment = 0.5;

double pose_array[15][4];
int num_states = 15;


double x_curr;
double y_curr;


// constructor
terpcopterMission::terpcopterMission():
main_state(ST_INIT),
rate(50.0)
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
    redtarget_Ipos_sub = nh.subscribe<geometry_msgs::PoseStamped>("InertialRedTargetPose", 10, &terpcopterMission::red_target_pos_cb, this); //check this same call back function
    blacktarget_Ipos_sub = nh.subscribe<geometry_msgs::PoseStamped>("InertialBlackTargetPose", 10, &terpcopterMission::black_target_pos_cb, this);
    hometarget_Ipos_sub = nh.subscribe<geometry_msgs::PoseStamped>("InertialHomeTargetPose", 10, &terpcopterMission::home_target_pos_cb, this);
    waypoints_sub = nh.subscribe<geometry_msgs::PoseArray>("waypoints_matlab", 10, &terpcopterMission::waypoints_matlab_cb, this);
    obstacle_sub = nh.subscribe<sensor_msgs::Range>("Terarangerone",10, &terpcopterMission::obstacle_cb,this);
    
    // publishers init
    local_pos_sp_pub = nh.advertise<geometry_msgs::PoseStamped>("mavros/setpoint_position/local", 10);
    state_pub = nh.advertise<std_msgs::String>("stateMachine", 10); //publishes state of the system

    // clients init
    land_client = nh.serviceClient<mavros_msgs::CommandTOL>("mavros/cmd/land");

    ROS_INFO("wait for FCU connection");
    wait_connect();

    ROS_INFO("send a few setpoints before switch to OFFBOARD mode");
    cmd_streams();

    // for landing service
    landing_last_request = ros::Time::now();
 
    // state machine
    while(ros::ok()){

        if(!current_state.armed){
            main_state = ST_INIT;
        }
        
        state_machine();
        ros::spinOnce();
        rate.sleep();
    }
}

void terpcopterMission::state_machine(void)
{
    ROS_DEBUG_ONCE("State Machine"); // message will be printed only once

    switch(main_state)
    {
        case ST_INIT:
        {
            state.data = "INIT";
            state_pub.publish(state);

            set_pos_sp(pose_c, pose_array[0][0], pose_array[0][1], pose_array[0][2]);
            set_yaw_sp(pose_c, pose_array[0][3]);
            local_pos_sp_pub.publish(pose_c);

            if(current_state.armed && current_state.mode == "OFFBOARD" && wp_received == 1)    // start mission
            {
                main_state = ST_TAKEOFF;
            
            }
        }
            break;

        case ST_TAKEOFF:
        {
            ROS_DEBUG_ONCE("Takeoff");

            state.data = "TAKEOFF";
            state_pub.publish(state);

            set_pos_sp(pose_c, pose_array[1][0], pose_array[1][1], pose_array[1][2]);
            set_yaw_sp(pose_c, pose_array[1][3]);
            local_pos_sp_pub.publish(pose_c);
            
            ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            abs(current_local_pos.pose.position.z - pose_c.pose.position.z));

            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    
                    cout<<"Takeoff Checked \n";
                    main_state = ST_MOVE1; // get digital number from display
                    
               }
        }
            break;

        case ST_MOVE1:
        {
            ROS_DEBUG_ONCE("Move1");
            //cout<<"In Move1\n";    
            state.data = "MOVE1";
            state_pub.publish(state);
            cout<<"Published Move1 \n";

            set_pos_sp(pose_c, pose_array[2][0], pose_array[2][1], pose_array[2][2]);
            set_yaw_sp(pose_c, pose_array[2][3]);
            local_pos_sp_pub.publish(pose_c);
            
            ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            abs(current_local_pos.pose.position.z - pose_c.pose.position.z));
            
            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    
                    cout<<"MOVE1 Checked \n";
                    main_state = ST_OBSTACLE;
                    
               }
        }
            break;

        case ST_OBSTACLE: // has to be changed to accommodate the Terraranger 
        {
            ROS_DEBUG_ONCE("Obstacle");
            //cout<<"In Move1\n";    
            state.data = "OBSTACLE2";
            state_pub.publish(state);
            cout<<"Published Obstacle2 \n";

            while (obstacle_range.range < 1.3){

                ROS_INFO("obstacle detected");
                
                set_pos_sp(pose_c, current_local_pos.pose.position.x + increment, current_local_pos.pose.position.y,
                 current_local_pos.pose.position.z); //moves to the left
                
                local_pos_sp_pub.publish(pose_c);
                cout<<"Published set points to avoid obstacle while going forward. \n";
               
               if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
                (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
                (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1)) {    
    
                    continue;    
               }

            }

            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
                (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
                (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1)) {    
                    
                    main_state = ST_BOXMOVE;
                    
               }
        }
        	break;
        
        case ST_BOXMOVE:
        {
        	ROS_DEBUG_ONCE("BoxMove");
            //cout<<"In Move1\n";    
            state.data = "BOXMOVE";
            state_pub.publish(state);
            cout<<"Published Boxmove \n";

            set_pos_sp(pose_c, pose_array[4][0], pose_array[4][1], pose_array[4][2]);
            set_yaw_sp(pose_c, pose_array[4][3]);
            local_pos_sp_pub.publish(pose_c);
            
            // ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            // current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            // ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            // abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            // abs(current_local_pos.pose.position.z - pose_c.pose.position.z));
            
            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    
                    cout<<"Box Move state Reached \n";
                    main_state = ST_SEARCH1;
                    
               }
        }
 			break;

        case ST_SEARCH1:
        {
			ROS_DEBUG_ONCE("Search1");
            //cout<<"In Move1\n";    
            state.data = "SEARCH1";
            state_pub.publish(state);
            //cout<<"Published Search1 \n";

            set_pos_sp(pose_c, pose_array[5][0], pose_array[5][1], pose_array[5][2]);
            set_yaw_sp(pose_c, pose_array[5][3]);
            local_pos_sp_pub.publish(pose_c);
           
            // ROS_INFO("MATLAB Waypoint pose-> X: [%f], Y: [%f], Z: [%f]", pose_c.pose.position.x, pose_c.pose.position.y,
            // pose_c.pose.position.z); 
            
            // ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            // current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            // ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            // abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            // abs(current_local_pos.pose.position.z - pose_c.pose.position.z));
            
            // check if red or black has been found
            // if red has been found, then go to red state.
            // if black has been found before red was found, then go to search 2

            //Checking if red has been spotted
            
            x_curr = current_local_pos.pose.position.x;
            y_curr = current_local_pos.pose.position.y;

            if (red_target_pos.header.frame_id == "redTargetDetected" && red_flag!= 1)
            {
            	cout<<"Red target detected\n";
                set_pos_sp(pose_c, x_curr, y_curr, 2.0);

            	main_state = ST_RED;

            }

            //Checking if red has been spotted
            if (black_target_pos.header.frame_id == "blackTargetDetected" && red_flag == 1)
            {
                cout<<"Red target detected\n";
                 set_pos_sp(pose_c, x_curr, y_curr, 2.0);

                main_state = ST_BLACK;

            }


            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    
                    cout<<"Search1 state Reached \n";
                    if (main_state != ST_RED && main_state != ST_BLACK)
                        main_state = ST_SEARCH2;

                    
               }
        }

        	break;
        
        case ST_SEARCH2:
        {
	        ROS_DEBUG_ONCE("Search2");
            //cout<<"In Move1\n";    
            state.data = "SEARCH2";
            state_pub.publish(state);
            //cout<<"Published Search2 \n";

            set_pos_sp(pose_c, pose_array[6][0], pose_array[6][1], pose_array[4][2]);
            set_yaw_sp(pose_c, pose_array[6][3]);
            local_pos_sp_pub.publish(pose_c);
            
            // ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            // current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            // ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            // abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            // abs(current_local_pos.pose.position.z - pose_c.pose.position.z));

             x_curr = current_local_pos.pose.position.x;
             y_curr = current_local_pos.pose.position.y;

            
            if (red_target_pos.header.frame_id == "redTargetDetected" && red_flag!= 1)
            {
            	cout<<"Red target detected\n";
                set_pos_sp(pose_c, x_curr, y_curr, 2.0);
            	main_state = ST_RED;

            }

            if (black_target_pos.header.frame_id == "blackTargetDetected" && red_flag == 1)
            {
                cout<<"Red target detected\n";
                 set_pos_sp(pose_c, x_curr, y_curr, 2.0);

                main_state = ST_BLACK;

            }


            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    cout<<"Search2 state Reached \n";
                        if (main_state != ST_RED && main_state != ST_BLACK)
                            main_state = ST_SEARCH3;

                        
                    
               }
        }

        break;

        case ST_SEARCH3:
        {
	        ROS_DEBUG_ONCE("Search3");
            //cout<<"In Move1\n";    
            state.data = "SEARCH3";
            state_pub.publish(state);
            //cout<<"Published Search3 \n";

            set_pos_sp(pose_c, pose_array[7][0], pose_array[7][1], pose_array[7][2]);
            set_yaw_sp(pose_c, pose_array[7][3]);
            local_pos_sp_pub.publish(pose_c);
            
            // ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            // current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            // ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            // abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            // abs(current_local_pos.pose.position.z - pose_c.pose.position.z));
            
             x_curr = current_local_pos.pose.position.x;
             y_curr = current_local_pos.pose.position.y;

            if (red_target_pos.header.frame_id == "redTargetDetected" && red_flag!= 1)
            {
            	cout<<"Red target detected\n";
                set_pos_sp(pose_c, x_curr, y_curr, 2.0);
            	main_state = ST_RED;

            }

            if (black_target_pos.header.frame_id == "blackTargetDetected" && red_flag == 1)
            {
                cout<<"Red target detected\n";
                 set_pos_sp(pose_c, x_curr, y_curr, 2.0);

                main_state = ST_BLACK;

            }


            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    cout<<"Search3 state Reached \n";
                    if (main_state != ST_RED && main_state != ST_BLACK)
                        main_state = ST_SEARCH4;

                    

               }
        }

        break;

        case ST_SEARCH4:
        {
	        ROS_DEBUG_ONCE("Search4");
            //cout<<"In Move1\n";    
            state.data = "SEARCH4";
            state_pub.publish(state);
            //cout<<"Published Search4 \n";

            set_pos_sp(pose_c, pose_array[8][0], pose_array[8][1], pose_array[8][2]);
            set_yaw_sp(pose_c, pose_array[8][3]);
            local_pos_sp_pub.publish(pose_c);
            
            // ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            // current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            // ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            // abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            // abs(current_local_pos.pose.position.z - pose_c.pose.position.z));
            
             x_curr = current_local_pos.pose.position.x;
             y_curr = current_local_pos.pose.position.y;

            if (red_target_pos.header.frame_id == "redTargetDetected" && red_flag!= 1)
            {
                cout<<"Red target detected\n";
                set_pos_sp(pose_c, x_curr, y_curr, 2.0);
                main_state = ST_RED;

            }

            if (black_target_pos.header.frame_id == "blackTargetDetected" && red_flag == 1)
            {
                cout<<"Black target detected\n";
                set_pos_sp(pose_c, x_curr, y_curr, 2.0);

                main_state = ST_BLACK;

            }

            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    
                    cout<<"Search4 state Reached \n";
                    if (main_state != ST_RED && main_state != ST_BLACK)
                        main_state = ST_SEARCH1; // if no target found go back to search 1

                    
                    
               }
        }
        break;


        case ST_RED:
        {
            ROS_DEBUG_ONCE("RED"); 

            state.data = "RED";
            state_pub.publish(state);

            while(counter1 !=200 && trial1!=3){
                ROS_INFO("hover for 10s trial: [%d]",trial1);
                local_pos_sp_pub.publish(pose_c);
                // set_pos_sp(pose_c, redtarget_Ipos_sub.position.x, redtarget_Ipos_sub.position.y, 1.0);
                pose_r.pose.position.x = red_target_pos.pose.position.x;
                pose_r.pose.position.y = red_target_pos.pose.position.y;
                pose_r.pose.position.z = 2.0;

                counter1 = counter1 + 1;
            }

            ROS_INFO("red pose-> X: [%f], Y: [%f], Z: [%f]", pose_r.pose.position.x, pose_r.pose.position.y, 2.0);

            local_pos_sp_pub.publish(pose_r);
           
            if((abs(current_local_pos.pose.position.x - pose_r.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_r.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_r.pose.position.z) < 0.1) && trial1==1)
               {
                    ROS_INFO("Inside if loop");
                    trial1= 2;
                    counter1= 0;
               }
            else{
            
            if ((abs(current_local_pos.pose.position.x - pose_r.pose.position.x) < 0.2) &&
               (abs(current_local_pos.pose.position.y - pose_r.pose.position.y) < 0.2) &&
               (abs(current_local_pos.pose.position.z - pose_r.pose.position.z) < 0.2))
               {
                    ROS_INFO("Inside else if and land loop");
                    red_flag= 1;
                    main_state= ST_LAND;
               }
            }
        }
            break;
        

        case ST_BLACK:
        {
            ROS_DEBUG_ONCE("BLACK"); 

            state.data = "BLACK";
            state_pub.publish(state);

            while(counter2 !=200 && trial2!=3){
                ROS_INFO("hover for 10s trial: [%d]",trial2);
                local_pos_sp_pub.publish(pose_c);
                // set_pos_sp(pose_c, redtarget_Ipos_sub.position.x, redtarget_Ipos_sub.position.y, 1.0);
                pose_b.pose.position.x = black_target_pos.pose.position.x;
                pose_b.pose.position.y = black_target_pos.pose.position.y;
                pose_b.pose.position.z = 2.0;

                counter2 = counter2 + 1;
            }

            ROS_INFO("black pose-> X: [%f], Y: [%f], Z: [%f]", pose_b.pose.position.x, pose_b.pose.position.y, 2.0);

            local_pos_sp_pub.publish(pose_b);
           
            if((abs(current_local_pos.pose.position.x - pose_b.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_b.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_b.pose.position.z) < 0.1) && trial2==1)
               {
                    ROS_INFO("Inside if loop");
                    trial2=2;
                    counter2=0;
               }
            else{
            
            if ((abs(current_local_pos.pose.position.x - pose_b.pose.position.x) < 0.2) &&
               (abs(current_local_pos.pose.position.y - pose_b.pose.position.y) < 0.2) &&
               (abs(current_local_pos.pose.position.z - pose_b.pose.position.z) < 0.2) )
               {
                    ROS_INFO("Inside else if and land loop");
                    black_flag =1; 
                    main_state= ST_LAND;
               }
            }
        }
            break;


        case ST_BACK1:
        {
            ROS_DEBUG_ONCE("Back1");
            //cout<<"In Move1\n";    
            state.data = "BACK1";
            state_pub.publish(state);
            cout<<"Published Back1 \n";

            set_pos_sp(pose_c, pose_array[9][0], pose_array[9][1], pose_array[9][2]);
            set_yaw_sp(pose_c, pose_array[9][3]);
            local_pos_sp_pub.publish(pose_c);
            
            // ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            // current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            // ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            // abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            // abs(current_local_pos.pose.position.z - pose_c.pose.position.z));
            
            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    
                    cout<<"Back1 Checked \n";
                    main_state = ST_OBSTACLE2;
                    
               }

        }

        case ST_OBSTACLE2:
        {
            ROS_DEBUG_ONCE("Obstacle");
            //cout<<"In Move1\n";    
            state.data = "OBSTACLE2";
            state_pub.publish(state);
            cout<<"Published Obstacle2 \n";

            while (obstacle_range.range < 1.3){

                ROS_INFO("obstacle detected");
                
                set_pos_sp(pose_c, current_local_pos.pose.position.x + increment, current_local_pos.pose.position.y,
                 current_local_pos.pose.position.z); // moves to the right

                local_pos_sp_pub.publish(pose_c);
                cout<<"Published set points to avoid obstacle while coming back. \n";

               if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
                (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
                (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1)) {    
    
                    continue;    
               }

            }

            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
                (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
                (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1)) {    
                    
                    main_state = ST_BACK2;
                    
               }
        }

        case ST_BACK2:
        {
            ROS_DEBUG_ONCE("Back2");
            //cout<<"In Move1\n";    
            state.data = "BACK2";
            state_pub.publish(state);
            cout<<"Published Back2 \n";

            set_pos_sp(pose_c, pose_array[10][0], pose_array[10][1], pose_array[10][2]);
            set_yaw_sp(pose_c, pose_array[10][3]);
            local_pos_sp_pub.publish(pose_c);
            
            ROS_INFO("local pose-> X: [%f], Y: [%f], Z: [%f]",current_local_pos.pose.position.x,
            current_local_pos.pose.position.y, current_local_pos.pose.position.z);
            
            ROS_INFO("Difference Pose-> X: [%f], Y: [%f], Z: [%f]",abs(current_local_pos.pose.position.x - pose_c.pose.position.x),
            abs(current_local_pos.pose.position.y - pose_c.pose.position.y),
            abs(current_local_pos.pose.position.z - pose_c.pose.position.z));
            
            if((abs(current_local_pos.pose.position.x - pose_c.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_c.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_c.pose.position.z) < 0.1))
               {    
                    cout<<"Back2 Checked \n";
                    main_state = ST_HOME;
                    
               }

        }

        case ST_HOME:
        {
            ROS_DEBUG_ONCE("HOME"); 

            state.data = "HOME";
            state_pub.publish(state);

            while(counter3 !=200 && trial3 !=3){
                ROS_INFO("hover for 10s trial: [%d]",trial3);
                local_pos_sp_pub.publish(pose_c);
                // set_pos_sp(pose_c, redtarget_Ipos_sub.position.x, redtarget_Ipos_sub.position.y, 1.0);
                pose_h.pose.position.x = home_target_pos.pose.position.x;
                pose_h.pose.position.y = home_target_pos.pose.position.y;
                pose_h.pose.position.z = 2.0;

                counter3 = counter3 + 1;
            }

            ROS_INFO("home pose-> X: [%f], Y: [%f], Z: [%f]", pose_h.pose.position.x, pose_h.pose.position.y, 2.0);

            local_pos_sp_pub.publish(pose_h);
           
            if((abs(current_local_pos.pose.position.x - pose_h.pose.position.x) < 0.1) &&
               (abs(current_local_pos.pose.position.y - pose_h.pose.position.y) < 0.1) &&
               (abs(current_local_pos.pose.position.z - pose_h.pose.position.z) < 0.1) && trial3==1)
               {
                    ROS_INFO("Inside if loop");
                    trial3=2;
                    counter3=0;
               }
            else{
            
            if ((abs(current_local_pos.pose.position.x - pose_h.pose.position.x) < 0.2) &&
               (abs(current_local_pos.pose.position.y - pose_h.pose.position.y) < 0.2) &&
               (abs(current_local_pos.pose.position.z - pose_h.pose.position.z) < 0.2) )
               {
                    ROS_INFO("Inside else if and land loop");
                    main_state= ST_LAND;
               }
            }
        }
            break;


        case ST_LAND:
        {
            // if(current_state.mode == "OFFBOARD"){
            //     // used same logic given in sample code for offboard mode
            //     if(current_state.mode != "AUTO.LAND" &&
            //     (ros::Time::now() - landing_last_request > ros::Duration(5.0))){
            //     if(land_client.call(landing_cmd) &&
            //         landing_cmd.response.success){
            //         ROS_INFO("AUTO LANDING!");
            //     }
            //     landing_last_request = ros::Time::now();
            //     }
            // }

            if(red_flag == 1){ // if this does not work wait for 30s 
                ROS_INFO("Red target landed going to search1");
                x_curr = pose_r.pose.position.x;
                y_curr = pose_r.pose.position.y;
                set_pos_sp(pose_c, x_curr, y_curr, 0.0);
                local_pos_sp_pub.publish(pose_c);
                
                if(current_local_pos.pose.position.z < 0.1)
                    {   
                        for (int i = 0; i<500; i++)
                        {}

                        cout<<"State has been made SEARCH1 \n";
                        main_state= ST_SEARCH1;
                }
            }

            if (black_flag == 1){
                ROS_INFO("Black target landing");
                x_curr = pose_b.pose.position.x;
                y_curr = pose_b.pose.position.y;
                set_pos_sp(pose_c, x_curr, y_curr, 0.0);
                local_pos_sp_pub.publish(pose_c);
                
                if(current_local_pos.pose.position.z < 0.1)
                    {   
                    cout<<"State has been made BACK1 \n";
                    main_state= ST_BACK1;
                }
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

//red target pose subscriber callback function
void terpcopterMission::red_target_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg)
{
    red_target_pos = *msg;
}

//black target pose subscriber callback function
void terpcopterMission::black_target_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg)
{
    black_target_pos = *msg;
}

//home target pose subscriber callback function
void terpcopterMission::home_target_pos_cb(const geometry_msgs::PoseStamped::ConstPtr& msg)
{
    home_target_pos = *msg;
}

//obstacle range subscriber callback function
void terpcopterMission::obstacle_cb(const sensor_msgs::Range::ConstPtr& msg)
{
    obstacle_range = *msg;
}

// waypoints pose subscriber callback function
void terpcopterMission::waypoints_matlab_cb(const geometry_msgs::PoseArray::ConstPtr& msg)
{   
    wp_received = 1;
    waypoints_matlab = *msg;
    
    int i =0;
    while (!waypoints_matlab.poses.empty() && i < num_states)
    {
        
        pose_array[i][0] = waypoints_matlab.poses[i].position.x;
        pose_array[i][1] = waypoints_matlab.poses[i].position.y;
        pose_array[i][2] = waypoints_matlab.poses[i].position.z;
        pose_array[i][3] = waypoints_matlab.poses[i].orientation.z;

        //cout<<"condition satisfied\n";
        //cout<<pose_array[i]<<"%d \t"<<i<<endl;
        i = i+1;
        
    }

    // for (int i = 0; i<num_states; i++)
    // {
    //     for(int j = 0;j<4;j++)
    //         cout<<pose_array[i][j]<<" ";
    //     cout<<endl;
    // }   


    //local_pos_sp_pub.publish(pose_c);      // publish display's local position

    ROS_INFO("MATLAB Waypoint pose-> X: [%f], Y: [%f], Z: [%f]",pose_c.pose.position.x, pose_c.pose.position.y,
    pose_c.pose.position.z); 
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

