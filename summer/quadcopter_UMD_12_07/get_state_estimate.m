
function state =  get_state_estimate(handles)

% THIS FUNCTION SUBSCRIBES TO IMU, LIDAR AND OPTICAL FLOW SENSOR DATA AND 
% RETURNS STATE ESTIMATE
% INPUTS:
%   handles: a structure containing handles to GUI objects
%
% OUTPUT:
%   state vector:
%     phi:          roll angle (rad)
%     theta:        pitch angle(rad)
%     psi_inertial: absolute heading of the quad-copter measured relative
%                   to the inertial north (rad) 
%     psi_relative: heading of the quad-copter masured relative to the
%                   initial heading of the quad-copter
%     Z_cur:        Current altitude of the quadcopter obtained after
%                   filtering LIDAR fata
%     Z_cur_unfiltered: Current altitude as measured by LIDAR
%     u_dot_forward:horizontal forward accleration
%     u_dot_crab:   horizontal crab acceleration
%     u_dot_forward:horizontal forward accleration
%     u_forward:    horizontal forward velocity
%     u_crab:       horizontal crab velocity
%     Z_d_dot:      vertical acceleration opposite to gravity vector 
% AUTHOR: SHUBHAM JENA
% AFFILIATION : UNIVERSITY OF MARYLAND 
% EMAIL : jena_shubham@iitkgp.ac.in

% THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THE GPLv3 LICENSE
% THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. ANY USE OF
% THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
% PROHIBITED.
%  
% BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO
% BE BOUND BY THE TERMS OF THIS LICENSE. THE LICENSOR GRANTS YOU THE RIGHTS
% CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH TERMS AND
% CONDITIONS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global imu_data lidarsub velocitysub;
persistent angle_offset z_hat t_prev Z_prev;
persistent lin_acc_imu_hat inertial_yaw_initial; 

%% get imu data
imu_msg = imu_data.LatestMessage;
if isempty(imu_data)
    state = NaN;
    disp('No imu data\n');
    return;
end
w = imu_msg.Orientation.W;
x = imu_msg.Orientation.X;
y = imu_msg.Orientation.Y;
z = imu_msg.Orientation.Z;

%% get accelerometer data
lin_acc_imu(1,1) = imu_msg.LinearAcceleration.X;
lin_acc_imu(2,1) = imu_msg.LinearAcceleration.Y;
lin_acc_imu(3,1) = imu_msg.LinearAcceleration.Z;

%% get lidar data
lidar_msg = lidarsub.LatestMessage;

%% get velocity data from fcu
velocity_msg = velocitysub.LatestMessage;

%% get Yaw pitch roll in inertial frame (NWU)
euler = quat2eul([w x y z]);
%yaw measured clock wise is negative.
state.psi_inertial = rad2deg(euler(1));
state.theta = rad2deg(euler(2));
state.phi = rad2deg(euler(3));

% if isempty(angle_offset), angle_offset = [state.psi_inertial;state.theta;state.phi]; end
% state.psi_inertial = state.psi_inertial - angle_offset(1);
% state.theta = state.theta - angle_offset(2);
% state.phi = state.phi - angle_offset(3);

%get relative yaw = - inertial yaw_intial - inertial yaw 
if isempty(inertial_yaw_initial), inertial_yaw_initial = state.psi_inertial; end
state.psi_relative = inertial_yaw_initial - state.psi_inertial;

%rounding off angles to 1 decimal place
state.psi_inertial = round(state.psi_inertial,1);
state.psi_relative = round(state.psi_relative,1);
state.theta = round(state.theta,1);
state.phi = round(state.phi,1);

%yaw lies between [-180 +180];
if state.psi_relative> 180, state.psi_relative = state.psi_relative-360;
elseif state.psi_relative<-180, state.psi_relative = 360+state.psi_relative;end

%display current yaw in gui
set(handles.si_a_editTextBox,'String',num2str(state.psi_relative));

%convert angle back to radians
state.psi_inertial = deg2rad(state.psi_inertial);
state.psi_relative = deg2rad(state.psi_relative);
state.theta = deg2rad(state.theta);
state.phi = deg2rad(state.phi);

%% filter accelerometer data, get accelerations in stability frame
if isempty(lin_acc_imu_hat)
   lin_acc_imu_hat = lin_acc_imu;
else
   lin_acc_imu_hat = kalman_filter(lin_acc_imu,lin_acc_imu_hat,[0.4;0.4;0.4]);
end
lin_acc_imu = lin_acc_imu_hat;
%rounding off acceleration to 3 decimal places
lin_acc_imu = round(lin_acc_imu,3);

%for a description of various frames used, see utilities/vectorConversions.m
acc_stab_frame = vectorConversions(lin_acc_imu,[state.psi_inertial;state.theta;state.phi],'imu2stab');
state.u_dot_forward = acc_stab_frame(1);
state.u_dot_crab = acc_stab_frame(2);
%get z_d_dot in inertial (NWU) frame
state.Z_d_dot = -acc_stab_frame(3) - 9.81;
  
%% get current height from lidar 
if isempty(lidar_msg)
    %disp('no lidar data');
    %get min range from lidar msg
    z_cur = 0.2;
    z_cur_unfiltered = z_cur;
    %handles.altitude_control_radio.Value=0;
else
    z_cur = lidar_msg.Range_;
    z_cur_unfiltered = z_cur;
    if isempty(z_hat),z_hat = z_cur;
    else, z_hat = kalman_filter(z_cur,z_hat,0.4);end
    z_cur = z_hat;
    
end
 
%lidar data is in imu frame; convert to inertial frame
state.Z_cur = cos(state.phi)*cos(state.theta)*z_cur;
%rounding off altitude measurement to 2 decimal places
state.Z_cur = round(state.Z_cur,2);
state.Z_cur_unfiltered = cos(state.phi)*cos(state.theta)*z_cur_unfiltered;

%display current height in gui
set(handles.h_a_editTextBox,'String',num2str(state.Z_cur));


%% get state.Z_dot & state.dt
t = clock;
if isempty(Z_prev) ||isempty(t_prev), state.Z_dot = 0; state.dt = 0;
else, state.dt = etime(t,t_prev); state.Z_dot = (state.Z_cur-Z_prev)/state.dt;end
Z_prev = state.Z_cur;
t_prev = t;  

%% get forward and crab speed
%mavros gives velocity data in ENU frame
v_enu(1,1) = velocity_msg.Twist.Linear.X;
v_enu(2,1) = velocity_msg.Twist.Linear.Y;
v_enu(3,1) = velocity_msg.Twist.Linear.Z;

%convert data to stability frame
v_stab = vectorConversions2(v_enu,[state.psi_inertial;state.theta;state.phi],'enu2stab');
%rounding off velocities to 2 decimal places
v_stab = round(v_stab,2);

state.u_forward = v_stab(1);
state.u_crab = v_stab(2);
%% create a dead band
% change this later
% if state.u_forward<0.1&&state.u_forward>-0.1
%     state.u_forward = 0;
% end
% if state.u_crab<0.1 && state.u_crab>-0.1
%     state.u_crab = 0;
% end
%%
%display velocities in gui
set(handles.u_f_a_editTextBox,'String',num2str(state.u_forward));
set(handles.u_c_a_editTextBox,'String',num2str(state.u_crab));

%log  velocities
     data2 = [v_enu(1) v_enu(2) v_enu(3) ...
              v_stab(1) v_stab(2) v_stab(3)...
              state.u_forward state.u_crab...
              state.psi_inertial state.theta state.phi...
              state.u_dot_forward state.u_dot_crab state.Z_d_dot...
              lin_acc_imu(1) lin_acc_imu(2) lin_acc_imu(3)];
     fname='accelerometer_data2.csv' ;
     fid=fopen(fname,'a');  
     fprintf(fid,'%6.6f,   %6.6f,   %6.6f,   %6.6f,    %6.6f,    %6.6f,    %6.6f,   %6.6f,   %6.6f,   %6.6f,    %6.6f,   %6.6f,      %6.6f,   %6.6f,    %6.6f,    %6.6f,    %6.6f\n',...
                  data2(1),data2(2),data2(3),data2(4), data2(5), data2(6), data2(7),data2(8),data2(9),data2(10),data2(11),data2(12),data2(13),data2(14),data2(15),data2(16),data2(17));
     fclose(fid);
     %disp('logging accelerometer data');

end

