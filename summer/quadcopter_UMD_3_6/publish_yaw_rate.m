function publish_yaw_rate()
clc
clear all
rosshutdown
rosinit
yawpub = rospublisher('/yawtopic', 'std_msgs/Float64');
pause(2);
yawmsg = rosmessage(yawpub);
i = 1;
r = robotics.Rate(1000);
while(1)
yawmsg.Data = i
send(yawpub,yawmsg);
i = i+2;
waitfor(r);
end
end