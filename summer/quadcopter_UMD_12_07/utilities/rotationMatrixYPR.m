function R = rotationMatrixYPR(psi,theta,phi)
% Rotation matrix for converting vector components from inertial frame to
% imu frame
% Inputs:
%   psi : yaw (rad)
%   theta : pitch (rad)
%   phi : roll (rad)
% 
% Output : 
%   R : 3x3 rotation matrix (yaw-pitch-roll sequence)
%   

R =  [cos(theta)*cos(psi) sin(phi)*sin(theta)*cos(psi) - cos(phi)*sin(psi) cos(phi)*sin(theta)*cos(psi)+sin(phi)*sin(psi);
     cos(theta)*sin(psi) sin(phi)*sin(theta)*sin(psi)+cos(phi)*cos(psi)   cos(phi)*sin(theta)*sin(psi)-sin(phi)*cos(psi);
     -sin(theta)                          sin(phi)*cos(theta)                           cos(phi)*cos(theta)]';


end