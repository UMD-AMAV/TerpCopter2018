function [u_stick_cmd,v_z_error_int]= altitudeController(state,handles,u_stick_cmd,params,u_stick_thr_init)
%ALTITUDE CONTROLLER FUNCTION 
% INPUTS:
%   handles:          a structure containing handles to GUI objects
%   state:            vector of current state of the quad
%   u_stick_cmd:      4*1 vector of control stick inputs
%   parmas:           parameters defined in param.m file
%   u_stick_thr_init: Thr stick input just before altitude controller is
%                     switched on; included to ensure smooth transition 
%                     from take-Off to altitude- hold
%
% OUTPUT:
%   u_stick_cmd:      (updated) 4*1 vector of control stick inputs
%   v_z_error_int: variable for accumulating integral error

% AUTHOR: SHUBHAM JENA
% AFFILIATdisp('Kp')ION : UNIVERSITY OF MARYLAND 
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


persistent t1 v_z_error_prev;
disp('altitude control running');

persistent stickcmdlast;

%get h_des,k_p_h  k_i_h k_d_h from user
k_p_h = handles.kph_slider.Value;
k_i_h = handles.kih_slider.Value;
k_d_h = handles.kdh_slider.Value;
Z_des = str2double(get(handles.h_des_editTextBox,'String'));
k_h   = handles. kh_slider.Value;
h_error =(Z_des-state.Z_cur);
       
  %************ cascaded PID control*********************************
  %postion control loop 
  %v_z_sp = k_h*h_error;
  v_z_sp = Z_des; % k_h*h_error;
  
  %constrain v_z_sp
  v_z_sp = max(-params.v_z_max,min(params.v_z_max,v_z_sp));
  
  %velocity control loop
  v_z_error = h_error; %v_z_sp - state.Z_dot;
  
  if isempty(v_z_error_prev), v_z_error_prev = 0; v_z_error_dot=0;
  else, v_z_error_dot = (v_z_error-v_z_error_prev)/state.dt; end%% TAKING STEP WISE DERIVATIVE
 
  v_z_error_prev = v_z_error;
   
  %v_z_error_dot = -k_h*state.Z_dot - state.Z_d_dot;
  %disp('%6.6f \n',v_z_error_dot);
  
  %calculate limits on delu
  delu_max= params.umax_throttle - u_stick_thr_init*(cos(state.theta)*cos(state.phi));
  delu_min = -params.umax_throttle -u_stick_thr_init*(cos(state.theta)*cos(state.phi));
  [delu, v_z_error_int] = PID(v_z_error,v_z_error_dot,params.v_z_error_int,[k_p_h;k_d_h;k_i_h],delu_max,delu_min,state.dt);

  %calculate thrust
  u_stick_cmd(1)= (delu+0.6)/(cos(state.theta)*cos(state.phi))+(u_stick_thr_init);
  u_stick_cmd(1) = max(-params.umax_throttle, min(params.umax_throttle,u_stick_cmd(1)));
  
  %disp('%6.6f \n',u_stick_cmd(1));
%    if ~isempty(stickcmdlast)
%     %rate limit 
%     limit= 1/5;
%     limit_value= (u_stick_cmd(1)-stickcmdlast)/state.dt ;
%     
%     if(limit_value > limit)
%         u_stick_cmd(1) = stickcmdlast + limit* state.dt;
%         
%     elseif (limit_value < -limit)
%         u_stick_cmd(1) = stickcmdlast - limit* state.dt;
%     end
%     
%     
%    end
%    stickcmdlast = u_stick_cmd(1);
  %save z_cur to a data file
  if isempty(t1), t1 = state.dt; else, t1 = t1+state.dt; end
  data = [t1 Z_des state.Z_cur state.Z_cur_unfiltered state.Z_dot state.Z_d_dot u_stick_cmd(1) v_z_sp];
  fname='altitude_control_data.csv' ;
  fid=fopen(fname,'a');  
  fprintf(fid,'%6.6f,%6.6f,%6.6f,%6.6f,%6.6f,%6.6f, %6.6f,%6.6f\n',data(1),data(2),data(3),data(4), data(5), data(6), data(7), data(8));
  fclose(fid);
