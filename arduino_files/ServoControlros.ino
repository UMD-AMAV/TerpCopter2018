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

void actuate(){
  for (int i=0;i<10;i++){
    servo1.write(10 + 6*i);
    delay(300);
  }
  for (int i=0;i<=10;i++){
    servo1.write(70 - 6*i);
    delay(500);
  }
}

void servo1_cb( const std_msgs::UInt16& cmd_msg){
  bool c = false;
  if (cmd_msg.data == 0){
    c = false;
    digitalWrite(3, LOW);  //toggle led
  }
  else {
    c = true;
  }

  if(c){
    actuate();
  }
}

void servo2_cb( const std_msgs::UInt16& cmd_msg){
  servo2.write(cmd_msg.data);  //toggle led 
}

ros::Subscriber<std_msgs::UInt16> sub1("servo1", servo1_cb);
ros::Subscriber<std_msgs::UInt16> sub2("servo2", servo2_cb);

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

// rostopic pub servo std_msgs/UInt16  <angle>
// rosrun rosserial_python serial_node.py /dev/ttyUSB0
