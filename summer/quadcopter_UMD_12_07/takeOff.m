function [u_stick_cmd,v_z_error_int_takeOff] = takeOff(state,handles,u_stick_cmd,params)
% THIS FUNCTION PERFORMS AUTOMATED TAKE-OFF AND SWITCHES ON THE ALTITUDE 
% CONTROLLER WHEN THE DESIRED HEIGHT IS REACHED
% INPUTS:
%   handles: a structure containing handles to GUI objects
%   state: vecotr of current state of the quad
%   u_stick_cmd: 4*1 vector of cotrol stick inputs
%   parmas: parameters defined in param.m file.
%
% OUTPUT:
%   u_stick_cmd
%   v_z_error_int_takeOff: variable for accumulating integral error

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

if 0
    %TODO:
    %logic for aborting take off goes here
    %if throttle stick is not at -1, abort 
    disp('vehicle already in air');
    disp('aborting takeoff');
    handles.takeOff_radio.Value = 0;
    return;

else    
   disp('takoff function running');
   disp(state.Z_cur);  
   eps  = 0.1;
%   Z_des = params.takeOffHeight;

%   %if takeOffComplete, switch on altitude control and return
%   takeOffComplete = abs(Z_des - state.Z_cur)<eps;
%   if takeOffComplete
%       set(handles.h_des_editTextBox,'String',num2str(Z_des));
%       handles.altitude_control_radio.Value = 1;
%       handles.takeOff_radio.Value = 0;
%       v_z_error_int_takeOff = [];
%       return;
%   end

%get gains from GUI
k_p_h = handles.kph_slider.Value;
k_i_h = handles.kih_slider.Value;
k_d_h = handles.kdh_slider.Value;

v_z_sp = params.takeOffSpeed;
v_z_error = v_z_sp - state.Z_dot;
v_z_error_dot = - state.Z_d_dot;

delu_max= 2;
delu_min = 0;
[delu, v_z_error_int_takeOff] = PID(v_z_error,v_z_error_dot,params.v_z_error_int_takeOff,[k_p_h;k_d_h;k_i_h],delu_max,delu_min,state.dt);

%calculate thrust
u_stick_cmd(1)= -1 + delu;
u_stick_cmd(1) = max(-params.umax_throttle, min(params.umax_throttle,u_stick_cmd(1)));
end

end