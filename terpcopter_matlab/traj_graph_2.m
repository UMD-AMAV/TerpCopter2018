% 
% THIS FILE SUBSCRIBES GRAPHS THE TRAJECTORIES OF POSITION X,Y,Z
% and plots them on the arena 

% AUTHORS: SAIMOULI KATRAGADDA, DEREK PALEY
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rosinit('10.1.10.204'); % only the first time
% set(gca,'xlim',[800 2000])
% set(gca,'xlim',[0 12294])

function traj_graph

pose = rossubscriber('/mavros/local_position/pose');

ax = 5; % m
tlag = 10; % sec
arena = [0 75 0 35]*0.3048; % m
home = [10,10]*0.3048; % m

yawPose = receive(pose,10);
quat=([yawPose.Pose.Orientation.W, yawPose.Pose.Orientation.X,...
        yawPose.Pose.Orientation.Y,yawPose.Pose.Orientation.Z]);
Eangles = rad2deg(quat2eul(quat));

yaw_offset = Eangles(1); % yaw offset deg


figure(gcf), clf
subplot(6,2,[1 3 5])
axis image, hold on
axis(ax*[-1 1 -1 1]), box on, grid on
xlabel('x (m)'), ylabel('y (m)')
pos_plot1 = plot(0,0,'ro','linewidth',2,'markersize',12);
set(pos_plot1,'markeredgecolor','r','markerfacecolor','w');
yaw_quiver1 = quiver(0,0,0,1);
set(yaw_quiver1,'linewidth',2);
title('local view')

subplot(6,2,[2 4 6])
axis image, hold on
axis(arena+ax*[-1 1 -1 1]), box on, grid on
xlabel('x (m)'), ylabel('y (m)')
pos_plot2 = plot(home(1),home(2),'ro','linewidth',2,'markersize',12);
plot(home(1),home(2),'ks')
set(pos_plot2,'markeredgecolor','r','markerfacecolor','w');
yaw_quiver2 = quiver(home(1),home(2),0,1);
set(yaw_quiver2,'linewidth',2);
perimeter_box = rectangle('position',[0 0 arena(2) arena(4)]);
title('arena view')

subplot(6,2,7); set(gca,'ylim',ax*[-1,1])
hold on, ylabel('x (m)'), box on, grid on

subplot(6,2,9); set(gca,'ylim',ax*[-1,1])
hold on, ylabel('y (m)'), box on, grid on

subplot(6,2,11); set(gca,'ylim',[-1,ax])
hold on, ylabel('z (m)'), box on, grid on
xlabel('time (sec)')

subplot(6,2,8); set(gca,'ylim',90*[-1,1])
hold on, ylabel('roll (deg)'), box on, grid on

subplot(6,2,10); set(gca,'ylim',90*[-1,1])
hold on, ylabel('pitch (deg)'), box on, grid on

subplot(6,2,12); set(gca,'ylim',180*[-1,1])
hold on, ylabel('yaw (deg)'), box on, grid on
xlabel('time (sec)')


t0 = [];
ii=1;
while (1)
    msgPose = receive(pose,10);
    
    %posX(ii) = msgPose.Pose.Position.X;
    %posY(ii) = msgPose.Pose.Position.Y;
    posZ(ii) = msgPose.Pose.Position.Z;
    %% Transformation of X,Y points to I frame
    posX(ii) = msgPose.Pose.Position.X * cos(deg2rad(yaw_offset)) - msgPose.Pose.Position.Y * sin(deg2rad(yaw_offset));
    posY(ii) = msgPose.Pose.Position.X * sin(deg2rad(yaw_offset)) + msgPose.Pose.Position.Y * cos(deg2rad(yaw_offset));
    %%
    posX_home(ii) = posX(ii)+home(1);
    posY_home(ii) = posY(ii)+home(2);

    quat=([msgPose.Pose.Orientation.W, msgPose.Pose.Orientation.X,...
        msgPose.Pose.Orientation.Y,msgPose.Pose.Orientation.Z]);
    Eangles = rad2deg(quat2eul(quat));
    yaw(ii) = Eangles(1) - yaw_offset;
    pitch(ii) = Eangles(2);
    roll(ii) = Eangles(3);
    
    abs_t = eval([int2str(msgPose.Header.Stamp.Sec) '.' ...
        int2str(msgPose.Header.Stamp.Nsec)]);
    if isempty(t0), t0 = abs_t; end
    t = abs_t-t0;
    
    subplot(6,2,7);
    plot(t,posX(ii),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,9);
    plot(t,posY(ii),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,11);
    plot(t,posZ(ii),'b.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,8);
    plot(t,roll(ii),'m.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,10);
    plot(t,pitch(ii),'m.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,12);
    plot(t,yaw(ii),'k.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,[1 3 5])
    plot(posX(ii),posY(ii),'r.');
    set(pos_plot1,'xdata',posX(ii),'ydata',posY(ii));
    set(yaw_quiver1,'xdata',posX(ii),'ydata',posY(ii),'udata', ...
        cos(yaw(ii)/180*pi), 'vdata',sin(yaw(ii)/180*pi));

    subplot(6,2,[2 4 6])
    plot(posX_home(ii),posY_home(ii),'r.');
    set(pos_plot2,'xdata',posX_home(ii),'ydata',posY_home(ii));
    set(yaw_quiver2,'xdata',posX_home(ii),'ydata',posY_home(ii),'udata', ...
        cos(yaw(ii)/180*pi), 'vdata',sin(yaw(ii)/180*pi));

    drawnow
    ii=ii+1;
end

