function [cur_yaw, cur_pitch, cur_roll, z_cur, z_cur_unfiltered, z_dot, z_d_dot, dt] =  disp_sensor_data(handles)

global imu_yawsub lidarsub;
persistent yaw_offset z_hat t_prev z_prev z_d_dot_hat;

%% display yaw_angle
imu_msg = imu_yawsub.LatestMessage;
w = imu_msg.Orientation.W;
x = imu_msg.Orientation.X;
y = imu_msg.Orientation.Y;
z = imu_msg.Orientation.Z;
% subtract g from, imu reading to get w_dot
w_dot = imu_msg.LinearAcceleration.Z - 9.81;

%TODO: apply transformation to get z_d_dot from w_dot
z_d_dot = w_dot;
%TODO: apply filter on z_d_dot
if isempty(z_d_dot_hat),z_d_dot_hat = z_d_dot;
    else, z_d_dot_hat = kalman_altitude(z_d_dot,z_d_dot_hat);end
    z_d_dot = z_d_dot_hat;
    
euler = quat2eul([w x y z]);
cur_yaw = euler(1);
cur_pitch = euler(2);
cur_roll = euler(3);
cur_yaw = rad2deg(cur_yaw);
cur_pitch = rad2deg(cur_pitch);
cur_roll = rad2deg(cur_roll);

cur_yaw = round(cur_yaw,1);
if isempty(yaw_offset), yaw_offset = cur_yaw; end

%yaw measured clock wise negative. 
%yaw lies between [-180 +180];
cur_yaw = cur_yaw - yaw_offset;
if cur_yaw> 180, cur_yaw = cur_yaw-360;
elseif cur_yaw<-180, cur_yaw = 360+cur_yaw;end

%display current yaw in gui
set(handles.si_a_editTextBox,'String',num2str(cur_yaw));
% disp('current_yaw');
% disp(cur_yaw);

%% display current altitude in gui
lidar_msg = lidarsub.LatestMessage;
if isempty(lidar_msg)
    disp('no lidar data');
    %get min range from lidar msg
    z_cur = 0.2;
    z_cur_unfiltered = z_cur;
    handles.altitude_control_radio.Value=0;
else
    z_cur = lidar_msg.Range_;
    z_cur_unfiltered = z_cur;
    if isempty(z_hat),z_hat = z_cur;
    else, z_hat = kalman_altitude(z_cur,z_hat);end
    z_cur = z_hat;
    
 end
%display current height in gui
set(handles.h_a_editTextBox,'String',num2str(z_cur));
% disp('altitude:');
%  z_cur


%get z_dot & dt
t = clock;
if isempty(z_prev) ||isempty(t_prev), z_dot = 0; dt = 0;
else, dt = etime(t,t_prev); z_dot = (z_cur-z_prev)/dt;end
z_prev = z_cur;
t_prev = t;  

end
