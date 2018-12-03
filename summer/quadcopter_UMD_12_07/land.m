function [u_stick_cmd,v_z_error_int_land] = land(state,handles,u_stick_cmd,params)
% THIS FUNCTION PERFORMS AUTOMATED LANDING 
% INPUTS:
%   handles: a structure containing handles to GUI objects
%   state: vector of current state of the quad
%   u_stick_cmd: 4*1 vector of cotrol stick inputs
%   parmas: parameters defined in param.m file.
%
% OUTPUT:
%   u_stick_cmd
%   v_z_error_int_land: variable for accumulating integral error

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

persistent u_stick_thr_cur;                        % 
% if state.Z_cur <=params.landCompleteHeight         % current alt (stateEst) <= land.Completion.desiredAlt
%     disp('vehicle already on ground');
%     disp('land complete');
%     handles.land_radio.Value = 0;                  %
%     u_stick_thr_cur = [];
%     v_z_error_int_land = [];
%     return;
% 
% else    
%    disp('land function running');
%    disp(state.Z_cur);  
%    eps  = 0.05;

  %if landComplete, switch off land radio and return
%   landComplete = abs(params.landCompleteHeight - state.Z_cur)<eps;
%   if landComplete
%       u_stick_cmd(1) = -1;
%       handles.land_radio.Value = 0;
%       handles.altitude_control_radio.Value = 0;
%       v_z_error_int_land = [];
%       u_stick_thr_cur = [];
%       return;
%   end
%switch off altitude controller if running
handles.altitude_control_radio.Value = 0;
%get gains from GUI
k_p_h = handles.kph_slider.Value;
k_i_h = handles.kih_slider.Value;
k_d_h = handles.kdh_slider.Value;

v_z_sp = -params.landSpeed;
v_z_error = v_z_sp - state.Z_dot;
v_z_error_dot = - state.Z_d_dot;

if isempty(u_stick_thr_cur), u_stick_thr_cur = handles.pax(1).YData;end
%calculate limits on delu
delu_max= params.umax_throttle - u_stick_thr_cur;
delu_min = -params.umax_throttle -u_stick_thr_cur;
[delu, v_z_error_int_land] = PID(v_z_error,v_z_error_dot,params.v_z_error_int_land,[k_p_h;k_d_h;k_i_h],delu_max,delu_min,state.dt);

%calculate thrust
u_stick_cmd(1)=  u_stick_thr_cur + delu;
u_stick_cmd(1) = max(-params.umax_throttle, min(params.umax_throttle,u_stick_cmd(1)));

end

end