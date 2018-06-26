 function controller_fcn(obj,evnt,handles)
tic
evnt_time = datestr(evnt.Data.time);
% cleanupObj = onCleanup(@cleanMeUp);
%load('temp.mat');
global imu_yawsub lidarsub;
% disp(imu_yawsub);
persistent t0 t0_h yaw_offset h_offset ; 
persistent h_error_sum h_error_prev;
persistent z_hat; % for filtering lidar data
persistent ctr;
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;

%display current imu data in gui
imu_msg = imu_yawsub.LatestMessage;
w = imu_msg.Orientation.W;
x = imu_msg.Orientation.X;
y = imu_msg.Orientation.Y;
z = imu_msg.Orientation.Z;
% [cur_yaw, cur_pitch, cur_roll] = quat2angle([x y z w]);
euler = quat2eul([w x y z]);
cur_yaw = euler(1);
cur_pitch = euler(2);
cur_roll = euler(3);
cur_yaw = rad2deg(cur_yaw);
cur_pitch = rad2deg(cur_pitch);
cur_roll = rad2deg(cur_roll);
%rounding up the current yaw to the nearest integer
%////////change later if needed/////////
cur_yaw = round(cur_yaw,1);

if isempty(yaw_offset), yaw_offset = cur_yaw; end
% yaw measured clock wise negative. yaw lies between [-180 +180];
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
    % disp('yaw control running');
    % get si_des and k_si from user
    gain = str2double(get(handles.k_si_editTextBox,'String'));
    des_yaw = str2double(get(handles.si_des_editTextBox,'String'));

    %get yaw error
    yaw_error = deg2rad((des_yaw - cur_yaw));
    yaw_error  = (atan2(sin(yaw_error),cos(yaw_error)));
    disp('yaw_error:');
    disp(rad2deg(yaw_error));
    u_stick_cmd(4) = -gain*yaw_error; % positve stick command gives clockwise rotation
    u_stick_cmd(4) = max(-1,min(1,u_stick_cmd(4)));


    %plot yaw error
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
% disp(z_cur);


%if height control button is on do this
if handles.altitude_control_radio.Value==1
   disp('altitude control running');
   %get h_des,k_p_h  k_i_h k_d_h from user
   k_p_h = str2double(get(handles.k_h_editTextBox,'String'))
   k_i_h = str2double(get(handles.k_h_i_textbox,'String'))
   k_d_h = str2double(get(handles.k_h_d_textbox,'String'))
   z_des = str2double(get(handles.h_des_editTextBox,'String'));
   
   theta = deg2rad(cur_pitch);
   phi = deg2rad(cur_roll);
   if abs(theta-pi/2)<0.04 || abs(phi-pi/2)<0.04
       disp('divide by zero error');
       handles.altitude_control_radio.Value=0;
       return;
   end
   
   h_error =(z_des-z_cur)
%    disp('h_error:');
%    disp(h_error);
%    
   % filter lidar data
   
   %***************PID control**************************************
   % parameters
   g = 9.81;
   m_quad = .406; %kg
   m_battery1 = .116; %kg
   m_battery2 = .184; %kg
   m = m_quad + m_battery1;
   %u_trim0 =20/29;
   %K = (m*g)/(u_trim0 + 1);
    
   
   if isempty(h_error_sum), h_error_sum = 0; end %intergral error
   if isempty(h_error_prev), h_error_prev = h_error; end %derivative
   
   del_e_h = h_error-h_error_prev;
   delu = (k_p_h*h_error+k_i_h*h_error_sum+k_d_h*del_e_h);%/(cos(theta)*cos(phi));
   
   u_stick_cmd(1) = 0+delu
   umax = 0.25;
   u_stick_cmd(1) = max(-umax, min(umax,u_stick_cmd(1)))
%    
% if isempty(ctr)
%     ctr = 1;
% else
%     ctr = ctr+1;
% end
% u_stick_cmd(1) = temp(ctr);
   
%trim(1) = u_trim0/(handles.trim_lim(1));
   h_error_sum = h_error_sum + h_error;
   h_error_prev = h_error;
   

%   plot h
%     tlag = 20;
%     abs_t = eval([int2str(lidar_msg.Header.Stamp.Sec) '.' ...
%     int2str(imu_msg.Header.Stamp.Nsec)]);
%     if isempty(t0_h), t0_h = abs_t; end
%     t1 = abs_t-t0_h;
%     figure(3);
%     plot(t1,z_cur,'r*-'); set(gca,'xlim',[max(t1-tlag,0) max(t1,1)])
%     set(gca,'ylim',[0 3]);
%     hold on, ylabel('z_cur'); grid on;
%     plot(t1,z_cur_unfiltered,'bo-'); set(gca,'xlim',[max(t1-tlag,0) max(t1,1)])
%     legend('z_filtered','z_unfiltered');
%     drawnow;
    
%     figure(4);
%     plot(t1,u_stick_cmd(1),'ro-'); set(gca,'xlim',[max(t1-tlag,0) max(t1,1)])
%     set(gca,'ylim',[0 3]);
%     hold on, ylabel('u'); grid on;
%     drawnow;
% save z_cur to a data file
 data = [cputime z_cur z_cur_unfiltered h_error del_e_h u_stick_cmd(1)...
         datestr(evnt.Data.time)];
% open file for saving lidar data
 fname='lidar_data_z1.csv' ;
 fid=fopen(fname,'a');  
 fprintf(fid,'%6.6f,%6.6f,%6.6f,%6.6f,%6.6f,%6.6f,%6.6f\n',data(1),data(2),data(3),data(4), data(5), data(6), data(7));
 dlmwrite('lidar_data_z',data,'roffset',0,'coffset',0,'-append' );
   disp('saving to file');
 fclose(fid); 
%  evnt_time = datestr(evnt.Data.time)

% fname='lidar_data_edot.txt' ;
%   fid=fopen(fname,'a');  
%    dlmwrite('lidar_data_edot',data(3),'roffset',0,'coffset',0,'-append' );
%    disp('saving to file');
%  fclose(fid); 


else 
    %reset integral term
    h_error_sum =[];
    h_error_prev = [];
    ctr = [];
end
%send stick commands
for i=1:4
    if u_stick_cmd(i) ~=inf|| trim(i)~=inf
        send_stick_cmd(u_stick_cmd,trim,handles);
        break;
    end
end
toc
 end

%% make plots
% subplot(3,1,1); set(gca,'ylim',[-180 180]);
% hold on, ylabel('Yaw '); grid on;
%     
% subplot(3,1,2); set(gca,'ylim',[-360 360]);
% hold on, ylabel('pitch'); grid on;
%     
% subplot(3,1,3); set(gca,'ylim',[-360 360]);
% hold on, ylabel('roll'); grid on;
%     
% abs_t = eval([int2str(imu_msg.Header.Stamp.Sec) '.' ...
% int2str(imu_msg.Header.Stamp.Nsec)]);
% if isempty(t0), t0 = abs_t; end
% t = abs_t-t0;
% 
% subplot(3,1,1)
% plot(t,(cur_yaw),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
%     
% subplot(3,1,2)
% plot(t,(cur_pitch),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
%     
% subplot(3,1,3)
% plot(t,(cur_roll),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
%%
%     function cleanMeUp()
%        % saves data to file (or could save to workspace)
%        fprintf('saving variables to file..\n');
%        filename = ['lidar_data','.mat'];
%        save(filename,'z_cur');
%     end
% end 