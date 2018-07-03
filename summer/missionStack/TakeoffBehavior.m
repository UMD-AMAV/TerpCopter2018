classdef TakeoffBehavior < handle
    properties
        behaviorName
        %Throttle
        K_height 
        height_d                %desired
        %Yaw
        K_yaw
        yaw_d                   %desired
        %Forward
        K_u
        u_d                     %desired
        %Side
        K_v
        v_d                     %desired
        
        %altitude limit for takeoff behavior
        z_takeoff
        
        
    end
    
    methods
        function node = TakeoffBehavior(behaviorName, K_height, height_d, K_yaw, yaw_d, K_u, u_d, K_v, v_d, z_takeoff)
            if (nargin > 0)
                node.behaviorName = behaviorName;
                node.K_height = K_height;
                node.height_d = height_d;
                node.K_yaw = K_yaw;
                node.yaw_d = yaw_d;
                node.K_u = K_u;
                node.u_d = u_d;
                node.K_v = K_v;
                node.v_d = v_d;
                node.z_takeoff = z_takeoff;
                
            end
        end
    end
end