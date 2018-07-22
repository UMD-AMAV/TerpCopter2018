function simple_controller_fun(src, evnt, handles)
if handles.altitude_control_radio.Value==0
    return;
end
% tic
global lidarsub;
persistent h_error_sum h_error_prev;
persistent z_hat; % for filtering lidar data
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;


%display current lidar data in gui
lidar_msg = lidarsub.LatestMessage;
if isempty(lidar_msg)
    disp('no lidar data');
    z_cur = NaN;
    set(handles.h_a_editTextBox,'String',num2str(z_cur));
    return;
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



   disp('altitude control running');
   %get h_des,k_p_h  k_i_h k_d_h from user
   k_p_h = str2double(get(handles.k_h_editTextBox,'String'));
   k_i_h = str2double(get(handles.k_h_i_textbox,'String'));
   k_d_h = str2double(get(handles.k_h_d_textbox,'String'));
   z_des = str2double(get(handles.h_des_editTextBox,'String'));
   
   
   h_error =(z_des-z_cur)
%    disp('h_error:');
%    disp(h_error);
%    
   %***************PID control**************************************
    
   if isempty(h_error_sum), h_error_sum = 0; end %intergral error
   if isempty(h_error_prev), h_error_prev = h_error; end %derivative
   
   del_e_h = h_error-h_error_prev;
   delu = (k_p_h*h_error+k_i_h*h_error_sum+k_d_h*del_e_h);%/(cos(theta)*cos(phi));
   
   u_stick_cmd(1) = 0+delu;
   umax = 1;
   u_stick_cmd(1) = max(-umax, min(umax,u_stick_cmd(1)));
   h_error_sum = h_error_sum + h_error;
   h_error_prev = h_error;
   
 data = [cputime z_cur z_cur_unfiltered h_error del_e_h u_stick_cmd(1)];
 fname='lidar_data_z2.csv' ;
 fid=fopen(fname,'a');  
 fprintf(fid,'%6.6f,%6.6f,%6.6f,%6.6f,%6.6f,%6.6f\n',data(1),data(2),data(3),data(4), data(5), data(6));
 fclose(fid);

 if (u_stick_cmd(1) ==inf && u_stick_cmd(2) ==inf && u_stick_cmd(3) ==inf...
     && u_stick_cmd(4) ==inf && trim(1) == inf && trim(2) == inf && trim(3) == inf &&...
     trim(4) == inf)
    disp('exiting controller fcn');
    return;
else
    send_stick_cmd(u_stick_cmd,trim,handles);
%  toc
end
