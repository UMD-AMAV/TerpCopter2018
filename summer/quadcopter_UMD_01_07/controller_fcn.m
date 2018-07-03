 function controller_fcn(obj,evnt,handles)
 
global imu_yawsub lidarsub;
persistent t0 t0_h yaw_offset h_offset ; 
persistent h_error_int h_error_prev;
persistent z_hat; % for filtering lidar data
persistent t_prev ctr ;
global t_c
global t_clock;

% t_c.AveragePeriod
% t_c.InstantPeriod

u_stick_cmd(1:4) = inf;
trim(1:4) = inf;

%get dt
t = clock;
if isempty(t_prev), dt = 0;
else, dt = etime(t,t_prev); end
t_prev = t;

%display current imu data in gui
imu_msg = imu_yawsub.LatestMessage;
w = imu_msg.Orientation.W;
x = imu_msg.Orientation.X;
y = imu_msg.Orientation.Y;
z = imu_msg.Orientation.Z;

euler = quat2eul([w x y z]);
cur_yaw = euler(1);
cur_pitch = euler(2);
cur_roll = euler(3);
cur_yaw = rad2deg(cur_yaw);
cur_pitch = rad2deg(cur_pitch);
cur_roll = rad2deg(cur_roll);

cur_yaw = round(cur_yaw,1);
if isempty(yaw_offset), yaw_offset = cur_yaw; end
%yaw measured clock wise negative. yaw lies 
%between [-180 +180];
cur_yaw = cur_yaw - yaw_offset;
if cur_yaw> 180, cur_yaw = cur_yaw-360;
elseif cur_yaw<-180, cur_yaw = 360+cur_yaw;
end

%display current yaw in gui
set(handles.si_a_editTextBox,'String',num2str(cur_yaw));
% disp('current_yaw');
% disp(cur_yaw);


%if yaw control button is on do this
if(handles.yaw_control_radio.Value == 1)
    disp('yaw control running');

    %get si_des and k_si from user
    gain = str2double(get(handles.k_si_editTextBox,'String'));
    des_yaw = str2double(get(handles.si_des_editTextBox,'String'));

    %get yaw error
    yaw_error = deg2rad((des_yaw - cur_yaw));
    yaw_error  = (atan2(sin(yaw_error),cos(yaw_error)));
    %disp('yaw_error:');
    %disp(rad2deg(yaw_error));
    %positve stick command gives clockwise rotation
    u_stick_cmd(4) = -gain*yaw_error;
    u_stick_cmd(4) = max(-1,min(1,u_stick_cmd(4)));


%     plot yaw error
%     tlag = 200;
%     abs_t = eval([int2str(imu_msg.Header.Stamp.Sec) '.' ...
%     int2str(imu_msg.Header.Stamp.Nsec)]);
%     if isempty(t0), t0 = abs_t; end
%     t = abs_t-t0;
%     figure(2);
%     plot(t,rad2deg(yaw_error),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
%     set(gca,'ylim',[-180 180]);
%     hold on, ylabel('Yaw error '); grid on;

end

%display current lidar data in gui
lidar_msg = lidarsub.LatestMessage;
if isempty(lidar_msg)
    disp('no lidar data');
    z_cur = 0.2;% get min range from lidar msg
    handles.altitude_control_radio.Value=0;
else
    z_cur = lidar_msg.Range_;
    z_cur_unfiltered = z_cur;
    if isempty(z_hat),z_hat = z_cur;
    else, z_hat = kalman_altitude(z_cur,z_hat);
    end
    z_cur = z_hat;
end

%display current height in gui
set(handles.h_a_editTextBox,'String',num2str(z_cur));
% disp('altitude:');
%  z_cur


%if height control button is on do this
if handles.altitude_control_radio.Value==1
   disp('altitude control running');
   %get h_des,k_p_h  k_i_h k_d_h from user
   k_p_h = handles.kph_slider.Value;
   k_i_h = handles.kih_slider.Value;
   k_d_h = handles.kdh_slider.Value;
   z_des = str2double(get(handles.h_des_editTextBox,'String'));
   

   theta = deg2rad(cur_pitch);
   phi = deg2rad(cur_roll);
   if abs(theta-pi/2)<0.04 || abs(phi-pi/2)<0.04
       disp('divide by zero error');
       handles.altitude_control_radio.Value=0;
       return;
   end
   
   h_error =(z_des-z_cur);
   %disp('h_error:');
   %disp(h_error);
    
   
%***************PID control**************************************
   
  if isempty(h_error_int), h_error_int = 0; end %intergral error
  if isempty(h_error_prev), h_error_prev = h_error; end %derivative
   
  
  if ~dt, delu = k_p_h*h_error;
  else
      e_h_dot = (h_error-h_error_prev)/dt;
      delu = (k_p_h*h_error+h_error_int+k_d_h*e_h_dot)/(cos(theta)*cos(phi));
  end 
  u_stick_cmd(1) = 0+delu;
  
  umax = 1;
  %anti-windup
  stop_h_error_int = (u_stick_cmd(1)>=umax && h_error>=0 )||(u_stick_cmd(1)<=-umax && h_error<=0 );
  
  h_error_prev = h_error;
  if ~stop_h_error_int, h_error_int = h_error_int + k_i_h*h_error*dt; end
  
  u_stick_cmd(1) = max(-umax, min(umax,u_stick_cmd(1)));
  
 %save z_cur to a data file
 data = [etime(t,t_clock) z_cur z_cur_unfiltered h_error e_h_dot u_stick_cmd(1)];
 fname='lidar_data_z2.csv' ;
 fid=fopen(fname,'a');  
 fprintf(fid,'%6.6f,%6.6f,%6.6f,%6.6f,%6.6f,%6.6f\n',data(1),data(2),data(3),data(4), data(5), data(6));
 fclose(fid);

else 
    %reset integral term
    h_error_int =[];
    h_error_prev = [];
    ctr = [];
end

if (u_stick_cmd(1) ==inf && u_stick_cmd(2) ==inf && u_stick_cmd(3) ==inf...
    && u_stick_cmd(4) ==inf && trim(1) == inf && trim(2) == inf && trim(3) == inf &&...
    trim(4) == inf)
    disp('exiting controller fcn');
    return;
else
     send_stick_cmd(u_stick_cmd,trim,handles);
end

end

 