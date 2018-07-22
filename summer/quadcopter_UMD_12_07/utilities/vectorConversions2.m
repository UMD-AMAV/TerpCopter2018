function vecB = vectorConversions2(vecA, angles, frameid)
%converts from enu to stability frame
%   1) 'enu' : body fixed enu frame (n always points along the front of the vehicle)
%        X: right of vehicle
%        Y: front of the vehicle
%        Z: up  (perp. to veh. lateral frame, alligned to thrust)
%    2) 'stab' : body-centered ned frame, (n always points along the front of the vehicle)
%        X : front of vehicle (Body X projected onto horizontal N-E plane)
%        Y : Right of vehicle (Body -Y projected onto horizontal N-E plane)
%        Z : down (parallel to gravity vector
vecA = vecA(:);
yaw = angles(1);
pitch = angles(2);
roll = angles(3);

if(strcmp(frameid,'enu2stab'))
    R = rotationMatrixYPR(yaw,0,pi);
elseif(strcmp(frameid,'stab2enu'))
    R = (rotationMatrixYPR(yaw,0,pi))';
else
    disp('invalid frameid');
    vecB = NaN;
    return;
end

vecB = R * vecA;
end