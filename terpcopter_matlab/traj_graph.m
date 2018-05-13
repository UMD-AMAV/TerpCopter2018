
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rosinit('10.1.10.204'); % only the first time, where IP is ROS MASTER

function traj_graph

cleanupObj = onCleanup(@cleanMeUp);

disp(' ')
disp('Welcome to Traj Graph!')
disp('Press q to quit')
disp(' ')

pose = rossubscriber('/mavros/local_position/pose');

ax = 5; % m
tlag = 10; % sec
arena = [0 75 0 35]*0.3048; % m
home = [10,10]*0.3048; % m
launch_position = home; % initial position for flight in arena coords

set(gcf,'CurrentCharacter','@');
try
    msgPose = receive(pose,10);
        % define offsets relative to initial pose
    %quat=([msgPose.Pose.Orientation.W,msgPose.Pose.Orientation.X,...
    %        msgPose.Pose.Orientation.Y,msgPose.Pose.Orientation.Z]);
    %Eangles = rad2deg(quat2eul(quat));
    %yaw_offset = Eangles(1);
    yaw_offset = -18; % orientation of arena +x axis (deg CCW from E)
    x_offset = msgPose.Pose.Position.X;
    y_offset = msgPose.Pose.Position.Y;
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
    yaw_offset = 0;
    x_offset = 0;
    y_offset = 0;
end

figure(gcf), clf
subplot(6,2,[1 3 5])
axis image, hold on
axis(ax*[-1 1 -1 1]),
box on, grid on
xlabel('x (m)'), ylabel('y (m)')
pos_plot1 = plot(0,0,'ro','linewidth',2,'markersize',12);
set(pos_plot1,'markeredgecolor','r','markerfacecolor','w');
yaw_quiver1 = quiver(0,0,0,1);
set(yaw_quiver1,'linewidth',2);
title('local view')
htext_local = text(-ax,ax,'','verticalalignment','top',...
    'horizontalalignment','left');

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
htext_arena = text(arena(1)-ax,arena(4)+ax,'','verticalalignment','top',...
    'horizontalalignment','left');

subplot(6,2,7); set(gca,'ylim',[arena(1)-ax arena(2)+ax])
hold on, ylabel('x arena (m)'), box on, grid on

subplot(6,2,9); set(gca,'ylim',[arena(3)-ax arena(3)+ax])
hold on, ylabel('y arena (m)'), box on, grid on

subplot(6,2,11); set(gca,'ylim',[-1,ax])
hold on, ylabel('z (m)'), box on, grid on
xlabel('time (sec)')

subplot(6,2,8); set(gca,'ylim',90*[-1,1])
hold on, ylabel('roll (deg)'), box on, grid on

subplot(6,2,10); set(gca,'ylim',90*[-1,1])
hold on, ylabel('pitch (deg)'), box on, grid on

subplot(6,2,12); set(gca,'ylim',180*[-1,1])
hold on, ylabel('yaw arena (deg)'), box on, grid on
xlabel('time (sec)')


t0 = [];
ii=1;
set(gcf,'CurrentCharacter','@');
try
while (1) 
    try
        msgPose = receive(pose,10);
    catch e
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
        continue
    end
    
    posX(ii) = msgPose.Pose.Position.X;
    posY(ii) = msgPose.Pose.Position.Y;
    posZ(ii) = msgPose.Pose.Position.Z;
    
    % Transformation of X,Y points to arena frame   
    posX_arena(ii) = (posX(ii)-x_offset) * cos(deg2rad(yaw_offset)) - ...
        (posY(ii)-y_offset) * sin(deg2rad(yaw_offset))+launch_position(1);
    posY_arena(ii) = (posX(ii)-x_offset) * sin(deg2rad(yaw_offset)) + ...
        (posY(ii)-y_offset) * cos(deg2rad(yaw_offset))+launch_position(2);
    
    quat=([msgPose.Pose.Orientation.W, msgPose.Pose.Orientation.X,...
        msgPose.Pose.Orientation.Y,msgPose.Pose.Orientation.Z]);
    Eangles = rad2deg(quat2eul(quat));
    yaw(ii) = Eangles(1);
    yaw_arena(ii) = yaw(ii)-yaw_offset;
    pitch(ii) = Eangles(2);
    roll(ii) = Eangles(3);
    
    abs_t = eval([int2str(msgPose.Header.Stamp.Sec) '.' ...
        int2str(msgPose.Header.Stamp.Nsec)]);
    if isempty(t0), t0 = abs_t; end
    t = abs_t-t0;
    
    subplot(6,2,7);
    plot(t,posX_arena(ii),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,9);
    plot(t,posY_arena(ii),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,11);
    plot(t,posZ(ii),'b.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,8);
    plot(t,roll(ii),'m.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,10);
    plot(t,pitch(ii),'m.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,12);
    plot(t,yaw_arena(ii),'k.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
    
    subplot(6,2,[1 3 5])
    plot(posX(ii),posY(ii),'r.');
    ax_box_local = ax*[-1 1 -1 1]+[posX(ii)*[1 1] posY(ii)*[1 1]];
    axis(ax_box_local),
    set(pos_plot1,'xdata',posX(ii),'ydata',posY(ii));
    set(yaw_quiver1,'xdata',posX(ii),'ydata',posY(ii),'udata', ...
        cos(yaw(ii)/180*pi), 'vdata',sin(yaw(ii)/180*pi));
    set(htext_local,'position',[ax_box_local([1 4]) 0], ...
        'string',['(t,x,y,yaw)=(' num2str(t,4) ',' ...
        num2str(posX(ii),3) ',' num2str(posY(ii),3) ...
        ',' num2str(yaw(ii)) ')'])
    
    subplot(6,2,[2 4 6])
    plot(posX_arena(ii),posY_arena(ii),'r.');
    set(pos_plot2,'xdata',posX_arena(ii),'ydata',posY_arena(ii));
    set(yaw_quiver2,'xdata',posX_arena(ii),'ydata',posY_arena(ii),'udata', ...
        cos(yaw_arena(ii)/180*pi), 'vdata',sin(yaw_arena(ii)/180*pi));
    set(htext_arena,'string',['(t,x,y,yaw)=(' num2str(t,4) ',' num2str(posX_arena(ii),3) ',' num2str(posY_arena(ii),3) ...
        ',' num2str(yaw_arena(ii)) ')'])

    % check for keys
    k=get(gcf,'CurrentCharacter');
    if k~='@' % has it changed from the dummy character?
        set(gcf,'CurrentCharacter','@'); % reset the character
        % now process the key as required
        if k=='q', break;
        end
    end
    
    drawnow
    ii=ii+1;
end
save
catch e
save
rethrow(e)
end


function cleanMeUp()

       % saves data to file (or could save to workspace)

       fprintf('saving variables to file...\n');

       filename = ['traj_graph' datestr(now,'yyyy-mm-dd_HHMMSS') '.mat'];

       save(filename);

end
end
