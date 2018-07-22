function u_stick_cmd = yawController(state,handles,u_stick_cmd)
%ALTITUDE CONTROLLER FUNCTION 
% INPUTS:
%   handles:          a structure containing handles to GUI objects
%   state:            vector of current state of the quad
%   u_stick_cmd:      4*1 vector of control stick inputs
%
% OUTPUT:
%   u_stick_cmd:      (updated) 4*1 vector of control stick inputs
%
% AUTHOR: SHUBHAM JENA
% AFFILIATION : UNIVERSITY OF MARYLAND 
% EMAIL : jena_shubham@iitkgp.ac.in

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

persistent t1;

disp('yaw control running');
    
    %get si_des and k_si from user
    gain = str2double(get(handles.k_si_editTextBox,'String'));
    des_relative_yaw = deg2rad(str2double(get(handles.si_des_editTextBox,'String')));
    
    %get yaw error
    yaw_error = (des_relative_yaw - state.psi_relative);
    yaw_error  = (atan2(sin(yaw_error),cos(yaw_error)));
    %disp('yaw_error:');
    %positve stick command gives clockwise rotation
    
    u_stick_cmd(4) = gain*yaw_error;
    u_stick_cmd(4) = max(-1,min(1,u_stick_cmd(4)));
    
  %save cur_yaw to a data file
  if isempty(t1), t1 = state.dt; else, t1 = t1+state.dt; end
  data = [t1 des_relative_yaw state.psi_relative u_stick_cmd(4)];
  fname='yaw_control_data.csv' ;
  fid=fopen(fname,'a');  
  fprintf(fid,'%6.6f,%6.6f, %6.6f, %6.6f\n',data(1),data(2),data(3), data(4));
  fclose(fid);

end