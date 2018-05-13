% arena to pixhawk (waypoints in arena frame and transforms to pixhawks)
function [posX_pixhawk, posY_pixhawk] = arena_to_local(posX_arena, posY_arena, ...
            yaw_offset, x_offset, y_offset, launch_position)
        
      r_Do_o = [launch_position(1); launch_position(2)]; % launch position 
      
      R_L_A = [sin(yaw_offset) cos(yaw_offset)    % rotation of local to arena
                cos(yaw_offset) -sin(yaw_offset)];
            
      r_p_o = [posX_arena; 
                posY_arena];
            
      pixhawk_pos = R_L_A * (r_p_o - r_Do_o);
      
      posX_pixhawk = pixhawk_pos(1);
      posY_pixhawk = pixhawk_pos(2);
            
      
%     posX_pixhawk = (x_offset*cos(deg2rad(yaw_offset))^2 + x_offset*sin(deg2rad(yaw_offset))^2 ...
%         - launch_position(2)*cos(deg2rad(yaw_offset)) + posY_arena*cos(deg2rad(yaw_offset)) - ...
%         launch_position(1)*sin(deg2rad(yaw_offset)) ...
%         + posX_arena*sin(deg2rad(yaw_offset)))/(cos(deg2rad(yaw_offset))^2 + sin(deg2rad(yaw_offset))^2);
%     
%     posY_pixhawk = (y_offset*cos(deg2rad(yaw_offset))^2 + y_offset*sin(deg2rad(yaw_offset))^2 ...
%         - launch_position(1)*cos(deg2rad(yaw_offset)) + posX_arena*cos(deg2rad(yaw_offset)) + ...
%         launch_position(2)*sin(deg2rad(yaw_offset)) ...
%         - posY_arena*sin(deg2rad(yaw_offset)))/(cos(deg2rad(yaw_offset))^2 + sin(deg2rad(yaw_offset))^2);
        
end

