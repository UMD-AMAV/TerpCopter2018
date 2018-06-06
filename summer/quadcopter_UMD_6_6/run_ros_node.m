function run_ros_node(h)
global imu_yawsub;
% if any controller is active do this
if(h.yaw_control_radio.Value==1)
   % initialise ros node if not running  already
%    if(~robotics.ros.internal.Global.isNodeActive)
%       rosinit;%******REPLACE WITH IP ADDRESS OF MASTER NODE***
%    end
       imu_yawsub = rossubscriber('/mavros/imu/data',{@yaw_controller,h},'BufferSize',1);
    else
        clear global imu_yawsub;
end
    

end
