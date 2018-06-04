function yaw_controller(src,msg,handles)
disp('yaw controller running');
disp(msg.Data);
% get si_des and k_si from user
gain = str2double(get(handles.k_si_editTextBox,'String'));
des_yaw = str2double(get(handles.si_des_editTextBox,'String'));
cur_yaw = mod(rad2deg(msg.Data),360);
set(handles.si_a_editTextBox,'String',num2str(cur_yaw));
    
u_stick_cmd(1:4) = inf;
yaw_error = deg2rad((des_yaw - cur_yaw));
yaw_error  = atan2(sin(yaw_error),cos(yaw_error))*180/3.14;
u_stick_cmd(4) = gain*yaw_error;
u_stick_cmd(4) = max(-1,min(1,u_stick_cmd(4)));
trim_scaled(1:4) = inf;
textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 
send_stick_cmd(u_stick_cmd,trim_scaled,...
handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec);
    
 