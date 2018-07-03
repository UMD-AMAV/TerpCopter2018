function controller_fcn2(obj,evnt,handles)
%disp('executing controller_fcn2');
persistent v_z_sp v_z_error_int;
persistent t1;
%persistent t0 t0_h  h_offset ctr; 
% 
%% display current imu & lidar data in gui
[cur_yaw, cur_pitch, cur_roll, z_cur, z_cur_unfiltered,z_dot, z_d_dot, dt] = disp_sensor_data(handles);

%%
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;
umax = 1;
v_z_max = 5;


%% if yaw control button is on run yaw controller
if(handles.yaw_control_radio.Value == 1)
    disp('yaw control running');
    %get si_des and k_si from user
    gain = str2double(get(handles.k_si_editTextBox,'String'));
    des_yaw = str2double(get(handles.si_des_editTextBox,'String'));
    %get yaw error
    yaw_error = deg2rad((des_yaw - cur_yaw));
    yaw_error  = (atan2(sin(yaw_error),cos(yaw_error)));
    %disp('yaw_error:');
    %positve stick command gives clockwise rotation
    u_stick_cmd(4) = -gain*yaw_error;
    u_stick_cmd(4) = max(-1,min(1,u_stick_cmd(4)));
end



%% if altitude control button is on run altitude control
if handles.altitude_control_radio.Value==1
   disp('altitude control running');
   %get h_des,k_p_h  k_i_h k_d_h from user
   k_p_h = handles.kph_slider.Value;
   k_i_h = handles.kih_slider.Value;
   k_d_h = handles.kdh_slider.Value;
   z_des = str2double(get(handles.h_des_editTextBox,'String'));
   k_h   = handles. kh_slider.Value;
   
   theta = deg2rad(cur_pitch);
   phi = deg2rad(cur_roll);
   if abs(theta-pi/2)<0.04 || abs(phi-pi/2)<0.04
      disp('divide by zero error');
      handles.altitude_control_radio.Value=0;
      return;
   end
   h_error =(z_des-z_cur);
   %disp('h_error:');
   %disp(h_error);\\
       
  %************ cascaded PID control*********************************
  %postion control loop
  
  %initialise v_z_sp to current velocity + k*h_error
  %if isempty(v_z_sp), v_z_sp = k_h*h_error + z_dot; 
  %else, v_z_sp = k_h*h_error + v_z_sp; end 
  v_z_sp = k_h*h_error;
  %constrain v_z_sp
  v_z_sp = max(-v_z_max,min(v_z_max,v_z_sp));
  
  %velocity control loop
  v_z_error = v_z_sp - z_dot;
  v_z_error_dot = -k_h*z_dot - z_d_dot;
  if isempty(v_z_error_int), v_z_error_int = 0; end
  
  %calculate thrust
  u_stick_cmd(1)= (0+(k_p_h*v_z_error+k_d_h*v_z_error_dot+ v_z_error_int))/(cos(theta)*cos(phi));
  u_stick_cmd(1) = max(-umax, min(umax,u_stick_cmd(1)));
  
  %anti-windup
  stop_v_z_error_int = (u_stick_cmd(1)>=umax && v_z_error>=0 )||(u_stick_cmd(1)<=-umax && v_z_error<=0);
  if ~stop_v_z_error_int, v_z_error_int = v_z_error_int + k_i_h*v_z_error*dt; end
  
 %save z_cur to a data file
 if isempty(t1), t1 = dt; else, t1 = t1+dt; end
 data = [t1 z_cur z_cur_unfiltered z_dot z_d_dot u_stick_cmd(1) v_z_sp];
 fname='altitude_control_data.csv' ;
 fid=fopen(fname,'a');  
 fprintf(fid,'%6.6f,%6.6f,%6.6f,%6.6f,%6.6f,%6.6f, %6.6f\n',data(1),data(2),data(3),data(4), data(5), data(6), data(7));
 fclose(fid);

else 
    %reset integral term
    v_z_error_int =[];
end

if (u_stick_cmd(1) ==inf && u_stick_cmd(2) ==inf && u_stick_cmd(3) ==inf...
    && u_stick_cmd(4) ==inf && trim(1) == inf && trim(2) == inf && trim(3) == inf &&...
    trim(4) == inf)
    %disp('exiting controller fcn');
    return;
else
     send_stick_cmd(u_stick_cmd,trim,handles);
end

end
%   plot yaw error
%   tlag = 200;
%   abs_t = eval([int2str(imu_msg.Header.Stamp.Sec) '.' ...
%   int2str(imu_msg.Header.Stamp.Nsec)]);
%   if isempty(t0), t0 = abs_t; end
%   t = abs_t-t0;
%   figure(2);
%   plot(t,rad2deg(yaw_error),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
%   set(gca,'ylim',[-180 180]);
%   hold on, ylabel('Yaw error '); grid on;

 