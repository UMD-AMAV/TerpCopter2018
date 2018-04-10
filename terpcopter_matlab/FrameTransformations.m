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
pose = rossubscriber('/mavros/local_position/pose');
visionPose = rossubscriber('/redTargetPose');
RedTargetI_pose = rospublisher('/InertialTargetPose','geometry_msgs/Pose');

msgIPose = rosmessage(RedTargetI_pose);

H_I_D= zeros(4,4);
H_D_C= zeros(4,4);
H_C_T= zeros(4,4);

t_D_C= [0.05;0;-0.03;1];
R_D_C= Rotxyz(0,'y'); %no rotation
H_D_C(1:3,1:3)= R_D_C;
H_D_C(:,4)= t_D_C;

X_I =0; Y_I =0;

while(1)
    msgPose = receive(pose,10);
    msgVPose = receive(visionPose,10);
    
    t_I_D= [msgPose.Pose.Position.X;
            msgPose.Pose.Position.Y;
            msgPose.Pose.Position.Z;
            1];
        
    R_I_D= quat2rotm([msgPose.Pose.Orientation.X,msgPose.Pose.Orientation.Y,...
        msgPose.Pose.Orientation.Z, msgPose.Pose.Orientation.W]);
    
    H_I_D(1:3,1:3)= R_I_D;
    H_I_D(:,4)= t_I_D;
    
    t_C_T= [msgVPose.Pose.Position.X;
            msgVPose.Pose.Position.Y;
            msgVPose.Pose.Position.Z;
            1];
        
    R_C_T= eye(3);
    
    H_C_T(1:3,1:3)= R_C_T;
    H_C_T(:,4)= t_C_T;
    
    H_I_T= H_I_D * H_D_C * H_C_T;
    
    R_I_C = R_I_D * R_D_C;
    t_I_T = t_I_D(1:3) + (R_I_C * t_C_T(1:3)) %X,Y pose of the target w/r global frame
    
    msgIPose.Position.X = t_I_T(1); %
    msgIPose.Position.Y = t_I_T(2);
    
    send(RedTargetI_pose,msgIPose);
end





    
