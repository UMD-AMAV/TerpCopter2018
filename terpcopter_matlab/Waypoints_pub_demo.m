% 
% THIS FILE PUBLISHES X,Y,Z WAYPOINTS

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
% mavros/setpoint_position/local; % mavros topic used to publish waypoints
function Waypoints_pub_demo

terpcopter_states = string(["INIT","TAKEOFF", "MOVE1"]);%, "OBSTACLE", "SEARCHBOX", "SEARCH",...
%"RED", "BLACK" , "RETURN1", "HOME"]);

[~,stateSize] = size(terpcopter_states);

home = [10,10]*0.3048; % in meters
launch_position = home; % initial position for flight in arena coords

% INSERT WAYPOINTS HERE 
%X(m) Y(m) Z(m) YAW(deg) W/r to (0,0) I frame of arena
arena_Waypoints = [launch_position(1) launch_position(2) 0 0;
                   launch_position(1) launch_position(2) 1.5 0; 
                   launch_position(1)+4 launch_position(2) 1.5 0];

%%
disp(' ')
disp('Welcome to Waypoint publisher!')
disp(' ')

filename2 = ['waypoint' datestr(now,'yyyy-mm-dd_HHMMSS') '.txt'];
fileID = fopen(filename2,'w');

% create our clean up object
% cleanupObj = onCleanup(@cleanMeUp);

% publish waypoints
waypointPub= rospublisher('waypoints_matlab','geometry_msgs/PoseArray');

% subscribe pose
current_pose = rossubscriber('/mavros/local_position/pose');
% subscribe state from state machine
state = rossubscriber('/stateMachine');

try
    %msgState = receive(state,10);
    msgPose = receive(current_pose,10);
    yaw_offset = 0; % orientation of arena +x axis (deg CCW from E)
    x_offset = msgPose.Pose.Position.X;
    y_offset = msgPose.Pose.Position.Y;
catch e
    fprintf(1,'The identifier was:\n%s',e.identifier);
    fprintf(1,'There was an error! The message was:\n%s',e.message);
    yaw_offset = 0;
    x_offset = 0;
    y_offset = 0;
end

msgWaypoint = rosmessage(waypointPub);

for kk=1:stateSize
    
    msgWaypoint.Poses(kk)= robotics.ros.msggen.geometry_msgs.Pose;
end

[length,~] = size(arena_Waypoints);
local_Waypoints = zeros(size(arena_Waypoints));
local_Waypoints(:,3:4) = arena_Waypoints(:,3:4);


%convert the waypoints from arena cord. to pixhawks
for ii = 1 : length
    [posX_local, posY_local] = arena_to_local(arena_Waypoints(ii,1), arena_Waypoints(ii,2), ...
            yaw_offset, x_offset, y_offset, launch_position);
        
    yaw_pixhawk = arena_to_local_orientation(arena_Waypoints(ii,4), yaw_offset);
        
    local_Waypoints(ii,1)= posX_local; 
    local_Waypoints(ii,2)= posY_local;
    local_Waypoints(ii,4)= yaw_pixhawk;
end

disp('Sending the following...')
local_Waypoints
        
for ii=1:stateSize
    msgWaypoint.Poses(ii).Position.X = local_Waypoints(ii,1);
    msgWaypoint.Poses(ii).Position.Y = local_Waypoints(ii,2);
    msgWaypoint.Poses(ii).Position.Z = local_Waypoints(ii,3);
    msgWaypoint.Poses(ii).Orientation.Z = local_Waypoints(ii,4); % YAW
    msgWaypoint.Header.Seq = ii;
end

rate = robotics.Rate(50);
reset(rate);

counter = 0;
while (counter < 500)
   send(waypointPub,msgWaypoint);
   waitfor(rate);
   counter = counter +1;
end

fprintf("Setpoints sent");

try
while (1)
   try 
        msgState = receive(state,10);
        msgPose = receive(current_pose,10);
   catch e
       fprintf(1,'The identifier was:\n%s',e.identifier);
       fprintf(1,'There was an error! The message was:\n%s',e.message);
       continue
   end
   
   send(waypointPub,msgWaypoint);
   waitfor(rate);
   
   if(msgState.Data == terpcopter_states(1))
       fprintf('INIT \n')
       
       fprintf(fileID,'%s \n',msgState.Data);
       fprintf(fileID,'X: %f, Y: %f, Z: %f \n',msgPose.Pose.Position.X,...
           msgPose.Pose.Position.Y,msgPose.Pose.Position.Z);
   end
    
   if(msgState.Data == terpcopter_states(2))
       fprintf('TAKEOFF \n')
       
       fprintf(fileID,'%s \n',msgState.Data);
       fprintf(fileID,'X: %f, Y: %f, Z: %f \n',msgPose.Pose.Position.X,...
           msgPose.Pose.Position.Y,msgPose.Pose.Position.Z);
   end
   
   if(msgState.Data == terpcopter_states(3))
       fprintf('MOVE1 \n')
       
       fprintf(fileID,'%s \n',msgState.Data);
       fprintf(fileID,'X: %f, Y: %f, Z: %f \n',msgPose.Pose.Position.X,...
           msgPose.Pose.Position.Y,msgPose.Pose.Position.Z);
   end
   
end
catch e
rethrow(e)
end

% arena to pixhawk (waypoints in arena frame and transforms to pixhawks)
% function [posX_pixhawk, posY_pixhawk] = arena_to_local(posX_arena, posY_arena, ...
%             yaw_offset, x_offset, y_offset, launch_position)
%         
% % singularity if yaw_offset= n*90 and n*270;
% %   posX_pixhawk = (x_offset*cos(deg2rad(yaw_offset))^2 + x_offset*sin(deg2rad(yaw_offset))^2 ... 
% %     - launch_position(1)*cos(deg2rad(yaw_offset)) + waypointX*cos(deg2rad(yaw_offset)) ... 
% %     - launch_position(2)*sin(deg2rad(yaw_offset))+ waypointY*sin(deg2rad(yaw_offset)))...
% %     /(cos(deg2rad(yaw_offset))^2 + sin(deg2rad(yaw_offset))^2);
% % 
% % 
% %   posY_pixhawk = (y_offset*cos(deg2rad(yaw_offset))^2 + y_offset*sin(deg2rad(yaw_offset))^2 ...
% %     - launch_position(2)*cos(deg2rad(yaw_offset)) + waypointY*cos(deg2rad(yaw_offset)) ...
% %     + launch_position(1)*sin(deg2rad(yaw_offset)) - waypointX*sin(deg2rad(yaw_offset))) ...
% %     /(cos(deg2rad(yaw_offset))^2 + sin(deg2rad(yaw_offset))^2);
% 
%     posX_pixhawk = (x_offset*cos(deg2rad(yaw_offset))^2 + x_offset*sin(deg2rad(yaw_offset))^2 ...
%         - launch_position(2)*cos(deg2rad(yaw_offset)) + posY_arena*cos(deg2rad(yaw_offset)) - ...
%         launch_position(1)*sin(deg2rad(yaw_offset)) ...
%         + posX_arena*sin(deg2rad(yaw_offset)))/(cos(deg2rad(yaw_offset))^2 + sin(deg2rad(yaw_offset))^2);
%     
%     posY_pixhawk = (y_offset*cos(deg2rad(yaw_offset))^2 + y_offset*sin(deg2rad(yaw_offset))^2 ...
%         - launch_position(1)*cos(deg2rad(yaw_offset)) + posX_arena*cos(deg2rad(yaw_offset)) + ...
%         launch_position(2)*sin(deg2rad(yaw_offset)) ...
%         - posY_arena*sin(deg2rad(yaw_offset)))/(cos(deg2rad(yaw_offset))^2 + sin(deg2rad(yaw_offset))^2);
%  
%         
% end

% function yaw_pixhawk = arena_to_local_orientation(yaw_arena, yaw_offset)
%     pitch = 0; roll = 0;
%     yaw_pixhawk = yaw_arena + yaw_offset;
% end

% 
% % function cleanMeUp()
% %         % saves data to file (or could save to workspace)
% %         fprintf('saving variables to file...\n');
% %         filename = ['waypoint' datestr(now,'yyyy-mm-dd_HHMMSS') '.mat'];
% %         save(filename);
% % end

end