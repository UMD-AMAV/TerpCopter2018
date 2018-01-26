#include <ros/ros.h>
#include <geometry_msgs/PoseStamped.h>
#include <mavros_msgs/CommandBool.h>
#include <mavros_msgs/SetMode.h>
#include <mavros_msgs/State.h>

// Pixhawk runs the px4 flight stack which operates on an  embedded RTOS.
// uORB: "micro Object Request Broker" is an asynchronous 
// publish-subscribe messaging API similar to ROS that serves
// as a message bus between controller modules and their device drivers
// for devices on the pixhawk.
// uORB is started on bootup.
// 
// External communication is enabled via a UART/UDP connection.
// MAVlink is a binary telemetry protocol through which messages
// can be sent and recieved via the UART/UDP connection.
// The MAVlink library defines message types that encode
// different MAV behaviors and states, and the message interfaces
// for these MAVlink messages and MAVros are how we communicate
// with the flight controller using the onboard computer (ODroid).

//supporting links:
// MAVLINK MESSAGES: http://mavlink.org/messages/common
// MAVROS PACAKGE DESCRIPTION: http://wiki.ros.org/mavros
//-------
//lets begin.



mavros_msgs::State current_state; //global var
// sys_status is a node created when mavros is started
// that handles FCU detection.
// Its message definition is:

//(mavros_msgs/State)}
//std_msgs/Header header
//bool connected
//bool armed
//bool guided
//string mode  ###PX4 native flight stack modes 
//uint8 system_status

// In main, a subscriber object listens for "State" messages 
// and in order to handle these messages, a callback function
// must be defined,
// A callback function to handle incomming State messages:

void state_cb(const mavros_msgs::State::ConstPtr& msg){
    current_state = *msg; //sets the global current_state var to the incomming State message
}

//"ConstPtr" significance: it is a typedef of boost::shared_ptr<msg const=" ">.
// This makes it so that instead of a copy of the data being past by value,
//  the msg is passed reference instead (more efficient ).
// Furthermore, it is a constant pointer, therefore, 
// you can modify the value that the pointer points to 
// but not the pointer value itself. References to current_state
// in main will be references to the actual incomming State object.




int main(int argc,char** argv){

    ros::init(argc,argv,"offb_node"); //initializes ROS client library. Last arg is default name of node
    ros::NodeHandle nh;               //creating NodeHandle object registers the program with the ROS master

    // creating a PosedStamped message publisher (usage explained later)
      ros::Publisher local_pos_pub = nh.advertise<geometry_msgs::PoseStamped>
            ("mavros/setpoint_position/local", 10);
    // An object of the Publisher class handles the task of 
    // publishing the message that we define it to publish
    // and on a topic that the use chooses ("mavros/setpoint_position/local").
    // The last argument (10) is the defined messafe queue size.
    // The Publisher object places the message in an outbox queue of this size,
    // and lets a separate thread behind the scenes actually deliver the message
    // to subcribing nodes.
    
    // creating a State topic subscriber
     ros::Subscriber state_sub = nh.subscribe<mavros_msgs::State>
            ("mavros/state", 10, state_cb);
    // The node "sys_status" which is started when mavros starts
    // handles flight controller detection.
    
    // sys_status publishes FCU state on topic: ~state (mavros_msgs/State)
    // Therefore we want to subscribe to this topic to know if the FCU is detected.
    // mavros_msgs::State message type:
    //  Raw message definition:
/*              std_msgs/Header header
                bool connected
                bool armed
                bool guided
                string mode
                uint8 system_status
*/ 
// Now a callback function is required to handle incomming State messages.
// It is defined above main{}


// ROS services allow for bidirectional, one-to-one, communication between nodes.
// Usually we publish and subscribe to topics  and the node doesn't care if any other node
// listens, recieves or even exsists to receive the message.
// A ROS service sends the message from the client node and actually waits for a response
// from the server node.
// Data a client node sends to a sever is called a request.
// Data a server sends back is called a response
// ServiceClient objects take arguments of specific service message types.
// So you fill that message object with relevant data and the service
// client object is then able to call that service, passing on the relevant data
// stored in the corresponding service message type.

// Later on we fill a CommandBool object with relevant info and pass it as
// an argument to the arming_client so we can use that service client to call
// for an arming command.

    ros::ServiceClient arming_client = nh.serviceClient<mavros_msgs::CommandBool>
            ("mavros/cmd/arming"); // this is the name of the specific service
                                   // we want the arming_client to use
    // CommandBool on the other hand is the particular service type
    /*Raw Message Definition for commandbool service type
    # Common type for switch commands
    bool value  # request value
    ---
    bool success   #response value
    uint8 result
    */
    // Data before the dashes makes up request data and after dashes makes up response data

     ros::ServiceClient set_mode_client = nh.serviceClient<mavros_msgs::SetMode>
            ("mavros/set_mode");
    // Definition of SetMode message is long, the useful bits for this node is:
            //string custom_mode	# string mode representation or integer ex: "OFFBOARD"
            //---
            //bool mode_sent	# Mode known/parsed correctly and SET_MODE are sent


    ros::Rate rate(20.0);
// px4 has a message timeout of 500ms, will revert to previous mode if this time exceeded b/w messages.
// A Rate object allows for control over how fast a loop runs (can be used to control message publishing rate).
// It takes an integer argument which is interpreted as a Hz value.
// The rate.sleep() method will cause the delay you want.
// This method takes into consideration the time taken in each loop
// to perform nontrivial calculations and deducts from the intended loop
// cycle time so that in the worst case if the time it takes to complete 
// the loop is greater than the intended rate time, rate.sleep()
// does not add any additional delay.


    while(ros::ok() && !current_state.connected){
        ros::spinOnce();
        rate.sleep();
    }
// This while loop checks if the node is in good standing with the ROS master
// and if the FCU has established a connection with the node.
// If it hasn't, it will continue to listen for State messages on the mavros/state topic
// and execute the associated callback function until it finally does connect with the FCU.

// ros::ok() checks if the node is operating normally. (return trues if it is)

 // When new messages arrive, they are stored in a queue until 
    // ROS gets a chance to execute the callback function. 
    // Callbacks are executed via a call to ros::spinOnce() or ros::spin().
    // ros::spinOnce() asks ros to execute all pending callbacks from ALL of the 
    // node's subscriptions and THEN returns control back to us.
    // ros::spin() asks ros to execute callbacks until the node shuts down 
    // equivalent to:
        //  while(ros::ok()){
        //      ros::spinOnce(); }


// -------------- at this point, connection has been made with FCU

// Now it's time get into OFFBOARD mode and then arm the MAV.

// One of the communication plugins loaded by mavros_node
// is the "sys_status" node (mentioned above).
// It publishes:
// ~state   (mavros_msgs/State) :  FCU state
// ~battery (mavros_msgs/BatteryStatus) : FCU battery status report. DEPRECATED
// ~battery (sensor_msgs/BatteryState)  :FCU battery status report. New in Kinetic
// extended_state (mavros_msgs/ExtendedState)  :  Landing detector and VTOL state.

// And also provides the following ROS service.

//*** node SERVICE ***  IMPORTANT ***
// ~set_mode (mavros_msgs/SetMode) :::Set FCU operation mode.
// PX4 native flight stack modes, such as OFFBOARD mode

//The service message type is mavros_msgs/SetMode ... lets make an object of this type.
    mavros_msgs::SetMode offb_set_mode;
// The message definition is sort of verbose (as is this node explanation) 
// so I will mention the useful part only.
// One of the request member variables is:
//    string    custom_mode 	# string mode representation or integer

// The only response variable of this service type is:
// bool mode_sent   
// so if the service call is sucessful, it returns true.

// This variable takes a string that is one of the native px4 flight modes (we are interested in OFFBOARD)
// This message will be the argument to the associated server client defined above.
// To populate this message with the intended flight mode, "OFFBOARD",
// set the appropriate request variable to "OFFBOARD" like this:
// offb_set_mode.request.custom_mode = "OFFBOARD";
// A service client object for this message is defined above
// and is the object that will take the populated SetMode object
// as an argument and call for a mode change.

// BUT.. before entering this mode, messages must already be streaming, 
// else the MAV mode switch is rejected and it reverts back to its previous mode

// Lets send some points that represent hovering at 2 meters above the ground.
// We can use a geometry_msgs::PosedStamped type message

    geometry_msgs::PoseStamped pose;
//this object has the following definition:
//Raw Message Definition:
//      # A Pose with reference coordinate frame and timestamp
//      Header header  ---->>> std_msgs/Header header
//      Pose pose      ---->>> geometry_msgs/Pose pose

//furthermore.. Pose looks like this..:
//geometry_msgs/Pose.msg
//Raw Message Definition
//# A representation of pose in free space, composed of position and orientation. 
//      Point position         ----->>>  geometry_msgs/Point position
//      Quaternion orientation ----->>>  geometry_msgs/Quaternion orientation

// and.... Point looks like:
//geometry_msgs/Point.msg
//Raw Message Definition
//# This contains the position of a point in free space
//      float64 x
//      float64 y
//      float64 z

// setting altitude of 2 meters:
    pose.pose.position.x = 0;
    pose.pose.position.y = 0;
    pose.pose.position.z = 2;

// Now lets stream a few of these messages
// A PosedStamped publisher object is defined above.

    for(int i = 100; ros::ok() && i > 0; --i){
        local_pos_pub.publish(pose);
        ros::spinOnce();
        rate.sleep();
    }
// Some messages have been sent..
// Recall that we streamed a few messages because before entering OFFBOARD mode 
// a few setpoints must already have started streaming.

// Returing to the "mavros_msgs::SetMode offb_set_mode " object..
// It is the service type which is accepted as an argument to 
// the set_mode_client which uses the service named "mavros/set_mode"
// that is provided by the "sys_status" mode.

// The service message object of type SetMode... "offb_set_mode"
// is now populated with information that sets its custom_mode member variable
// to "OFFBOARD"

    offb_set_mode.request.custom_mode = "OFFBOARD";

// note.. we have not called the service to go into offboard mode.. 
// we have just modified a component of the message that is passed on to the 
// service client later.



// To request a mode switch requires a ROS service call using the
// "mavros/cmd/arming" service provided by the "command" node.
// The"command" node  sends "COMMAND_LONG" messages to the FCU
// "COMMAND_LONG" type is mavlink defined type.
// Our service client object for this service is set_mode_client (defined above)

// When it is called it will look like: "set_mode_client.call(offb_set_mode)"
//This happens later.. some more set up to take care of.




// Setting the mode is one thing.. we must also arm the MAV


// This is done using the "mavros/cmd/arming" service provided by 
// the "command" node.
// This service changes the arming status of the MAV.
// Near the beginning of the program, a ServiceClient object is defined
// for the "mavros/cmd/arming" service.
// Note that the arugment type is the service type "CommandBool".

// The "command" node sends data to the FCU using 
// the MAVlink message structure "COMMAND_LONG"

// COMMAND_LONG encodes a command to the MAV with up to 7 parameters

// COMMAND_LONG data structure: (relevant to the "command" node that has the arming service)
/*Field Name      	Type    	Description

target_system	    uint8_t 	System which should execute the command
target_component	uint8_t	    Component which should execute the command, 0 for all components
command         	uint16_t	Command ID, as defined by MAV_CMD enum.
confirmation    	uint8_t	    0: First transmission of this command. 1-255: Confirmation transmissions (e.g. for kill command)
param1          	float   	Parameter 1, as defined by MAV_CMD enum.
param2          	float   	Parameter 2, as defined by MAV_CMD enum.
param3          	float   	Parameter 3, as defined by MAV_CMD enum.
param4          	float   	Parameter 4, as defined by MAV_CMD enum.
param5          	float   	Parameter 5, as defined by MAV_CMD enum.
param6          	float   	Parameter 6, as defined by MAV_CMD enum.
param7          	float	    Parameter 7, as defined by MAV_CMD enum.
*/

 
/// As just noted... the service message type passed as an argument
// to the arming service client is of type CommandBool... 
// lets make an object of this type:
    mavros_msgs::CommandBool arm_cmd;
 
// Raw message definition:
//mavros_msgs/CommandBool.srv
//Raw Message Definition:
//# Common type for switch commands
//bool value
//---
//bool success
//uint8 result




 //Just now, I mentioned that the "command" node which offers the arming service
 // sends commands of type COMMAND_LONG to the FCU (see COMMAND_LONG message structure above).
 
 // Of particular interest is the "command" field that takes a uint16_t value 
 // that represents a specific command ID defined by the MAV_CMD enumeration
 // which is part of the comman MAVlink message set. (cataloged here http://mavlink.org/messages/common)
 // Each particular command ID represents a command that the MAV can execute.
 // We may be interested in CMD ID 176: MAV_CMD_DO_SET_MODE which sets the system mode
 // as defined by the MAV_MODE enum. 
 // MAV_MODE enum contains values that correspond to particular flags
 // that set that encode the MAV mode.
 // example of a MAV_MODE mode flag:
// CMD-ID	Field Name	                    Description
// 128	    MAV_MODE_FLAG_SAFETY_ARMED	    0b10000000, MAV safety set to armed. Motors are enabled / running / can start. Ready to fly. 

//

// So now lets return to that CommandBool object that was made.
// Now the request member variable "value" is set to true

    arm_cmd.request.value = true;
// Now later on we can pass this to the service client 
// and under the hood, the FCU will attempt to arm.



//                   LETS ARM AND FLY!
// ------------------------------------------------------------------
// At this point all relevant data structures have been initialized 
// and other objects created to handle node processes.


    ros::Time last_request = ros::Time::now(); // gets current time and names it "last_request"

// Main while loop. Service calls to go into offboard, arm, and publish set point message
// to get MAV to hover at 2m

while(ros::ok()){
    
    if(current_state.mode != "OFFBOARD", // if MAV not in OFFBOARD mode 
            && (ros::Time::now()-last_request >ros::Duration(5.0)))
            //seconds condition will make sure the following service calls
            // occur every 5 seconds.. so as to not overload the FCU. Logic here is similar to rate.sleep()
        {
            if(set_mode_client.call(offb_set_mode) 
                    && offb_set_mode.response.mode_sent) // if the service reponse "bool mode_sent" returns true
                {//comment on the first condition:
                // within the ros::ServiceClient Class Reference
                // bool call (Service &service) is a public member function declaration that
                // returns true if the service call succeeds 
                
                ROS_INFO("OFFBOARD ENABLED");
                //ROS_INFO is printf style output stream, default output to terminal.
                //Could also use ROS_INFO_STREAM, provides c++ style output to terminal.
                }
                
            last_request = ros::Time::now(); // reset for next loop
        }
        
    else{
            if (!current_state.armed && // is the Mav not armed ?
                    (ros::Time::now()-last_request >ros::Duration(5.0))) // execute loop every 5 seconds
                {           
                if(arming_client.call(arm_cmd) && arm_cmd.response.success)
                    {
                        ROS_INFO("VEHICLE ARMED");                    
                    }
                last_request = ros::Time::now(); // reset for next loop
                
                }   
            }
            
        local_pos_pub.publish(pose); // publish goal altitude of 2 meters
        ros::spinOnce();  // execute outstanding callbacks
        rate.sleep()       // maintain loop rate
    } // exit while loop
    
    return 0;
}
