% 
% THIS FILE SUBSCRIBES IMU raw data

% AUTHORS: SAIMOULI KATRAGADDA
% AFFILIATION : UNIVERSITY OF MARYLAND 
% EMAIL : SKATRAGA@TERPMAIL.UMD.EDU

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

function rawSensordata 
    disp('');
    disp('Welcome to raw sensor reading script');
    disp('Press cnt + c to end')
    disp('');
    
    tlag = 20; % sec
    Imu_raw= rossubscriber('/mavros/imu/data_raw'); %subscribe imu data
    
    
    figure(gcf), clf
    subplot(3,1,1); %set(gca,'ylim')
    hold on, ylabel('LinearAccelerationX (m/s^2)'); grid on;
    
    subplot(3,1,2); %set(gca,'ylim')
    hold on, ylabel('LinearAccelerationY (m/s^2)'); grid on;
    
    subplot(3,1,3); %set(gca,'ylim')
    hold on, ylabel('LinearAccelerationZ (m/s^2)'); grid on;
    
 ii=1; 
 t0 = [];
 try
 while(1)
    try
        Imu_raw_msg = receive(Imu_raw,10);
    catch e
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
        continue
    end
    
    abs_t = eval([int2str(Imu_raw_msg.Header.Stamp.Sec) '.' ...
        int2str(Imu_raw_msg.Header.Stamp.Nsec)]);
    if isempty(t0), t0 = abs_t; end
    t = abs_t-t0;
    
    lin_ax(ii) = Imu_raw_msg.LinearAcceleration.X;
    lin_ay(ii) = Imu_raw_msg.LinearAcceleration.Y;
    lin_az(ii) = Imu_raw_msg.LinearAcceleration.Z;
    
    omega_x(ii) = Imu_raw_msg.AngularVelocity.X;
    omega_y(ii) = Imu_raw_msg.AngularVelocity.Y;
    omega_z(ii) = Imu_raw_msg.AngularVelocity.Z;

% DOUBLE CHECK THESE LINES 
%     w(ii) = Imu_raw_msg.Orientation.W;
%     x(ii) = Imu_raw_msg.Orientation.X;
%     y(ii) = Imu_raw_msg.Orientation.Y;
%     z(ii) = Imu_raw_msg.Orientation.Z;
% 
%     [yaw(ii), ~, ~] = quat2angle([ w(ii) x(ii) y(ii) z(ii)]);
    
  
    subplot(3,1,1)
    plot(t,lin_ax,'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(3,1,2)
    plot(t,lin_ay,'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(3,1,3)
    plot(t,lin_az,'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
       
    ii = ii + 1;  
    
end  
catch e
rethrow(e)
end 
end