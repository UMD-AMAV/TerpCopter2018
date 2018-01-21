/*
if (cmd_msg.data != 0) {
    while(!cmd_msg.data) {
      servo.write(60 - i*n); //set servo angle, should be from 0-180
      if (i < 60) {
        i++;
      }
      else if (i > 60 || i < 2) {
        n = n * -1;
      }
    }
  }
  else {
    ;
  }
  */

/*

#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
#endif

#include <Servo.h> 
#include <ros.h>

#include <std_msgs/UInt16.h>

ros::NodeHandle  nh;

Servo servo1;
Servo servo2;

void servo1_cb( const std_msgs::UInt16& cmd_msg){
  servo1.write(cmd_msg.data[0]); //set servo angle, should be from 0-180  
  digitalWrite(3, HIGH-digitalRead(3));  //toggle led  
}

void servo2_cb( const std_msgs::UInt16& cmd_msg){
  servo2.write(cmd_msg.data[1]);
  digitalWrite(3, HIGH-digitalRead(3));  //toggle led 
}

ros::Subscriber<std_msgs::UInt16> sub("servo1", servo1_cb);
ros::Subscriber<std_msgs::UInt16> sub("servo2", servo2_cb);

void setup(){
  pinMode(3, OUTPUT);
  
  nh.initNode();
  nh.subscribe(sub1);
  nh.subscribe(sub2);
  
  servo1.attach(9); //attach it to pin 9
  servo2.attach(10); //attach it to pin 10
}

void loop(){
  nh.spinOnce();
  delay(20);
}
*/
   /*
   
#if (ARDUINO >= 100)
 #include <Arduino.h>
#else
 #include <WProgram.h>
#endif

#include <Servo.h> 
#include <ros.h>
#include <std_msgs/UInt16.h>
#include <std_msgs/String.h>


ros::NodeHandle  nh;

Servo servo;

char i = 0;
int n = 1;

void servo_cb( const std_msgs::UInt16& cmd_msg){
  i = cmd_msg.data;
  servo.write(cmd_msg.data); //set servo angle, should be from 0-180  
  digitalWrite(13, HIGH-digitalRead(13));  //toggle led  
}


ros::Subscriber<std_msgs::UInt16> sub("servo", servo_cb);

std_msgs::String str_msg;
ros::Publisher chatter("chatter", &str_msg);

void setup(){
  pinMode(13, OUTPUT);
  nh.initNode();
  nh.subscribe(sub);
  nh.advertise(chatter);
  servo.attach(9); //attach it to pin 9
}

void loop(){
  str_msg.data = i;
  chatter.publish( &str_msg );
  nh.spinOnce();
  delay(500);
}

*/
