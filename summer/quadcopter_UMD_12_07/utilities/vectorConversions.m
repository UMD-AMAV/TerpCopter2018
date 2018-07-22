function vecB = vectorConversions(vecA, angles, frameid)
% Inputs:
%   frameid : 
%   Possible conversions: 'imu2ned', 'imu2inert', 'enu2ned', 'enu2ned',
%   'enu2imu'
%   angles : 3 x 1 vector of yaw-pitch-roll reported by IMU (rad)                            

% Note:
%   Reference Frames:
%   1) 'imu' : body-fixed IMU frame 
%        X : front 
%        Y : left
%        Z : up (perp. to veh. lateral frame, alligned to thrust)
%   2) 'ned' : body-centered ned frame, (n always points along the front of the vehicle)
%        X : front of vehicle (Body X projected onto horizontal N-E plane)
%        Y : Right of vehicle (Body -Y projected onto horizontal N-E plane)
%        Z : down (parallel to gravity vector)
%           Note: only DOF is yaw
%   3) 'inert' : inertial frame NWU
%        X : inertial north
%        Y : inertial west
%        Z : up (opposite to gravity vector)
%   4) 'enu' : body fixed enu frame (n always points along the front of the vehicle)
%        X: right of vehicle
%        Y: front of the vehicle
%        Z: up  (perp. to veh. lateral frame, alligned to thrust)

vecA = vecA(:);
yaw = angles(1);
pitch = angles(2);
roll = angles(3);

if(strcmp(frameid,'inert2imu'))
    R = rotationMatrixYPR(yaw,pitch,roll);
elseif(strcmp(frameid,'imu2inert'))
    R = (rotationMatrixYPR(yaw,pitch,roll))';

elseif(strcmp(frameid,'inert2ned'))
    R = rotationMatrixYPR(yaw,0,pi);
elseif(strcmp(frameid,'ned2inert'))
    R = rotationMatrixYPR(yaw,0,pi)';

elseif(strcmp(frameid,'inert2enu'))
	R = rotationMatrixYPR(pi/2+yaw,roll,-pitch);
elseif(strcmp(frameid,'enu2inert'))
	R = (rotationMatrixYPR(pi/2+yaw,roll,-pitch))';

elseif(strcmp(frameid,'stab2imu'))
    R = rotationMatrixYPR(pi,pi+pitch,roll);
elseif(strcmp(frameid,'imu2stab'))
	R = (rotationMatrixYPR(pi,pi+pitch,roll))';

elseif(strcmp(frameid,'enu2imu'))
	R = rotationMatrixYPR(pi/2,0,0);
elseif(strcmp(frameid,'imu2enu'))
	R = (rotationMatrixYPR(pi/2,0,0))';

elseif(strcmp(frameid,'ned2enu'))
	R = rotationMatrixYPR(-pi/2,pi+roll,-pitch);
elseif(strcmp(frameid,'enu2ned'))
	R = (rotationMatrixYPR(-pi/2,pi+roll,-pitch))';

else
    disp('invalid frameid');
    vecB = NaN;
    return;
end


vecB = R * vecA;
end