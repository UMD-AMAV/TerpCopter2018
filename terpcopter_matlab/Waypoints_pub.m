% 
% THIS FILE PUBLISHES X,Y,Z WAYPOINTS

% AUTHORS: DEREK PALEY, SAIMOULI KATRAGADDA
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
function Waypoints_pub

% INSERT WAYPOINTS HERE %X Y Z
arena_Waypoints = [0 0 2; 
                   1 0 1.5];
%%
disp(' ')
disp('Welcome to Waypoint publisher!')
disp('Press q to quit')
disp(' ')

waypointPub= rospublisher('mavros/setpoint_position/local','geometry_msgs/Pose');
pose = rossubscriber('/mavros/local_position/pose');

home = [10,10]*0.3048; % m
launch_position = home; % initial position for flight in arena coords

try
    msgPose = receive(pose,10);
    yaw_offset = 6; % orientation of arena +x axis (deg CCW from E)
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

[length,~] = size(arena_Waypoints);
local_Waypoints = zeros(size(arena_Waypoints));
local_Waypoints(:,3) = arena_Waypoints(:,3);

%convert the waypoints from arena cord. to pixhawks
for ii = 1 : length
    [posX_local, posY_local] = arena_to_local(arena_Waypoints(ii,1), arena_Waypoints(ii,2), ...
            yaw_offset, x_offset, y_offset, launch_position);
        
    local_Waypoints(ii,1)= posX_local; 
    local_Waypoints(ii,2)= posY_local; 
    
end

% INIT TAKEOFF WAYPOINT1 if(OBSTACLE (move increments of 0.2m until obstacle))
% WAYPOINT2(search area) REDTARGET BLACKSQUARE 
% (return flight) HOME WAYPOINT
jj= 0;
while (jj ~= length)
   
   msgWaypoint.Position.X = local_Waypoints(jj,1); 
   msgWaypoint.Position.Y = local_Waypoints(jj,2);
   msgWaypoint.Position.Z = local_Waypoints(jj,3);
   
   send(waypointPub,msgWaypoint);
   fprintf('%f Waypoint published',jj);
   jj = jj + 1;
   
   % check for keys
    k=get(gcf,'CurrentCharacter');
    if k~='@' % has it changed from the dummy character?
        set(gcf,'CurrentCharacter','@'); % reset the character
        % now process the key as required
        if k=='q', break;
        end
    end
    
end
save('Waypoint');
end

% arena to pixhawk (waypoints in arena frame and transforms to pixhawks)
function [posX_pixhawk, posY_pixhawk] = arena_to_local(waypointX, waypointY, ...
            yaw_offset, x_offset, y_offset, launch_position)
        
% singularity if yaw_offset= n*90 and n*270;
        posX_pixhawk = (waypointX - launch_position(1) + x_offset*cos(yaw_offset) +...
            waypointY*sin(yaw_offset)- y_offset*sin(yaw_offset)) / cos(yawoffset);
        
        posY_pixhawk = (waypointY - launch_position(2) - waypointX*sin(yaw_offset) +...
            x_offset*sin(yaw_offset) + y_offset*cos(yaw_offset))/ cos(yaw_offset);
end
