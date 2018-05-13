% 
% THIS FILE SUBSCRIBES TO THE TARGET'S POSE IN THE BODY 
% FRAME AND CONVERTS TO THE POSE (X,Y) IN THE INERTIAL FRAME

% AUTHOR: SAIMOULI KATRAGADDA
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
function [] = blacktargetTransformations()
   
%% CHANGE THESE VARIABLES AT THE COMPETETION
    home = [10,10]*0.3048; % in meters
    launch_position = home; % initial position for flight in arena coords
    %t_D_C= [0.085;0;-0.03;1]; %camera w/r to drone frame
    
    % AND YAW_OFFSET
%%    
    filename2 = ['black' datestr(now,'yyyy-mm-dd_HHMMSS') '.txt'];
    fileID = fopen(filename2,'w');

    % Subscribers 
    try
        pose = rossubscriber('/mavros/local_position/pose');
        BlackvisionPose = rossubscriber('/blackTargetPose');
    catch e
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
    end
    
    % Publishers 
    BlackTargetI_pose = rospublisher('/InertialBlackTargetPose','geometry_msgs/PoseStamped');
  
    % Messages
    msgBlack_IPose = rosmessage(BlackTargetI_pose);

    t_I_D= zeros(3,1); %Drone w/r to world frame
    R_D_C= Rotxyz(0,'y'); %no rotation
    t_C_T= zeros(3,1); %target w/r to camera frame
    
    try
        msgPose = receive(pose,10);
        yaw_offset = -20; % orientation of arena +x axis (deg CCW from E)
        x_offset = msgPose.Pose.Position.X;
        y_offset = msgPose.Pose.Position.Y;
    catch e
        fprintf(1,'The identifier was:\n%s',e.identifier);
        fprintf(1,'There was an error! The message was:\n%s',e.message);
        yaw_offset = 0;
        x_offset = 0;
        y_offset = 0;
    end
 
   while(1)
        msgPose  = receive(pose,10);
        
        msgBPose = receive(BlackvisionPose,10);
      
        msgBPose.Header.FrameId
        
        t_I_D= [msgPose.Pose.Position.X;
                msgPose.Pose.Position.Y;
                msgPose.Pose.Position.Z;
                ];

        R_I_D= quat2rotm([msgPose.Pose.Orientation.X,msgPose.Pose.Orientation.Y,...
            msgPose.Pose.Orientation.Z, msgPose.Pose.Orientation.W]);

            
        t_C_Tb= [msgBPose.Pose.Position.X; % black target
                msgBPose.Pose.Position.Y;
                msgBPose.Pose.Position.Z;
                ];
            
        R_I_C = R_I_D * R_D_C;
        t_I_T = t_I_D + (R_I_C * t_C_Tb); %X,Y pose of the target w/r global frame
        
        fprintf(fileID,'t_I_Tx: %f, t_I_Ty: %f',t_I_T(1),...
           t_I_T(2));
        
        
%         fprintf(fileID,'piahwkx: %f, pixhawky: %f',pixhawkX,...
%            pixhawkX);
        
%         [pixhawkXb, pixhawkYb] = arena_to_local(t_I_Tb(1), t_I_Tb(2), ...
%             yaw_offset, x_offset, y_offset, launch_position);

%         fprintf(fileID,'piahwkXb: %f, pixhawkYb: %f',pixhawkXb,...
%            pixhawkYb);

        
        msgBlack_IPose.Pose.Position.X = t_I_T(1); 
        msgBlack_IPose.Pose.Position.Y = t_I_T(2);
        msgBlack_IPose.Header.FrameId = msgBPose.Header.FrameId;

        send(BlackTargetI_pose,msgBlack_IPose);
    end
end





    