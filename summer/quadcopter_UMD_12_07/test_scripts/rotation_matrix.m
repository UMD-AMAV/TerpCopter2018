function vecB = rotation_matrix(vecA,angles,frameid)
psi = angles(1);
theta = angles(2);
phi = angles(3);

if(strcmp(frameid,'b2s'))
    %rotate from body frame to stability frame
    R = [cos(theta)   sin(theta)*sin(phi)   sin(theta)*cos(phi);
          0              cos(phi)              -sin(phi);     
         -sin(theta)    sin(phi)*cos(theta)    cos(phi)* cos(theta)];

elseif(strcmp(frameid,'b2i'))
    %rotate from body frame to inertial frame
    R =  [cos(theta)*cos(psi) sin(phi)*sin(theta)*cos(psi) - cos(phi)*sin(si) cos(phi)*sin(theta)*cos(psi)+sin(phi)*sin(psi);
         cos(theta)*sin(psi) sin(phi)*sin(theta)*sin(psi)+cos(phi)*cos(psi)   cos(phi)*sin(theta)*sin(psi)-sin(phi)*cos(psi);
         -sin(theta)                          sin(phi)*cos(theta)                           cos(phi)*cos(theta)];
end

vecB = R * vecA;