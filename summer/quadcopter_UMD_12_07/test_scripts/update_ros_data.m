function update_ros_data(src,msg,h)
% disp('executing update_ros_data');
if(~isvalid(src)), return; end
w = msg.Orientation.W;
x = msg.Orientation.X;
y = msg.Orientation.Y;
z = msg.Orientation.Z;
% [cur_yaw, cur_pitch, cur_roll] = quat2angle([x y z w]);
euler = quat2eul([w x y z]);
cur_yaw = euler(1);
cur_pitch = euler(2);
cur_roll = euler(3);
cur_yaw = rad2deg(cur_yaw);
cur_pitch = rad2deg(cur_pitch);
cur_roll = rad2deg(cur_roll);

%************rounding up the current yaw to the nearest integer
%////////change later if needed/////////
cur_yaw = round(cur_yaw,0);

 persistent t0 yaw_offset ; 
% tlag = 20;
 if isempty(yaw_offset), yaw_offset = cur_yaw; end
 cur_yaw = cur_yaw - yaw_offset;
 % yaw measured clock wise negative. yaw lies between [-180 +180];
 if cur_yaw> 180, cur_yaw = cur_yaw-360;
 elseif cur_yaw<-180, cur_yaw = 360+cur_yaw;
 end
 
 %display current yaw in gui
set(h.si_a_editTextBox,'String',num2str(cur_yaw));
disp('executing update_ros_data: current_yaw');
disp(cur_yaw);
end