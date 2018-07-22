function [u_stick_cmd,v_forward_error_int, v_crab_error_int]=forwardCrabSpeedController(state,handles,u_stick_cmd,params)
%FORWARD AND CRAB SPEED CONTROLLER FUNCTION 
% INPUTS:
%   handles:          a structure containing handles to GUI objects
%   state:            vector of current state of the quad
%   u_stick_cmd:      4*1 vector of control stick inputs
%   parmas:           parameters defined in param.m file
%
% OUTPUT:
%   u_stick_cmd:         (updated) 4*1 vector of control stick inputs
%   v_forward_error_int: variables for accumulating integral error
%   v_crab_error_int:

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
%check if altitude controller is running
if isnan(u_stick_cmd(1))
   disp('cannot run speed controller, altitude control not running\n');
   v_forward_error_int = params.v_forward_error_int;
   v_crab_error_int = params.v_crab_error_int;
else
   disp('horizontal speed controller running');
   %get desired forward and crab speed from user
   u_forward_des = str2double(get(handles.u_f_des_editTextBox,'String'));
   u_crab_des = str2double(get(handles.u_c_des_editTextBox,'String'));

    %get pid gains from user
    K_u_f = [ handles.kpuf_slider.Value;
              handles.kduf_slider.Value;
              handles.kiuf_slider.Value];
          
    K_u_c = [ handles.kpuc_slider.Value;
              handles.kduc_slider.Value;
              handles.kiuc_slider.Value];

    %calculate error & derivative of error
    v_e_forward = u_forward_des - state.u_forward;
    v_e_crab  = u_crab_des - state.u_crab;
    v_e_forward_dot = -state.u_dot_forward;
    v_e_crab_dot = -state.u_dot_crab;

    %calculate horizontal thrust setpoints
    [thr_sp_forward, v_forward_error_int] = ...
    PID(v_e_forward,v_e_forward_dot,params.v_forward_error_int,K_u_f,params.umax_throttle,-params.umax_throttle,state.dt);
    
    [thr_sp_crab, v_crab_error_int] = ...
    PID(v_e_crab,v_e_crab_dot,params.v_crab_error_int,K_u_c,params.umax_throttle,-params.umax_throttle,state.dt);
    
    %limit thrust setpoint magnitudes
    %NOTE: assume that thrust is linearly related to control stick input
    %Relation: T = slope*(u_stick_thr_net+1);
    %slope = (m*params.g)/(u_stick_thr_net_hover+1);
    
    %calculate net throttle input
    thr_trim = handles.slider2.Value;
    u_stick_thr_net = (u_stick_cmd(1)*handles.stick_lim(1) + thr_trim*handles.trim_lim(1))...
                            /(handles.stick_lim(1)+handles.trim_lim(1));
    %get slope                    
    slope = params.m_net*params.g/( u_stick_thr_net+1);
    
    %get max allowed thrust in horizontal plane
    T_XY_max = slope * sqrt(4 - (u_stick_thr_net+1)*(u_stick_thr_net+1)) -1;
    T_XY_max_tilt = slope*(u_stick_thr_net+1)*cos(state.phi)*cos(state.theta)*tan(params.tilt_max);
    T_XY_max = min(T_XY_max,T_XY_max_tilt);
    
    %saturate horizontal thrust setpoints
    mag = sqrt(thr_sp_forward*thr_sp_forward + thr_sp_crab*thr_sp_crab);
    if mag > T_XY_max
        thr_sp_forward = thr_sp_forward * T_XY_max/mag;
        thr_sp_crab = thr_sp_crab * T_XY_max/mag;
    end
    
    %calculate control stick inputs for roll and pitch
    u_stick_cmd(2) = thr_sp_crab;
    u_stick_cmd(3) = thr_sp_forward;
    
    u_stick_cmd(2) = max(-params.umax_rollPitch, min(params.umax_rollPitch,u_stick_cmd(2)));
    u_stick_cmd(3) = max(-params.umax_rollPitch, min(params.umax_rollPitch,u_stick_cmd(3)));
    
    %save speed control data to file
    if isempty(t1), t1 = state.dt; else, t1 = t1+state.dt; end
    data2 = [t1 u_forward_des u_crab_des state.u_forward state.u_crab u_stick_cmd(2) u_stick_cmd(3)];
    fname='speed_control_data.csv' ;
    fid2=fopen(fname,'a');  
    fprintf(fid2,'%6.6f,%6.6f,%6.6f,%6.6f,%6.6f,%6.6f, %6.6f\n',data2(1),data2(2),data2(3),data2(4), data2(5), data2(6), data2(7));
    fclose(fid2);
   
end

end