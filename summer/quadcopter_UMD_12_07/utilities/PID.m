function [u, e_int] = PID(e,e_dot,e_int,K,umax,umin,dt)
%BASIC PID CONTROLLER
%example PID(v_z_error,v_z_error_dot,params.v_z_error_int,[k_p_h;k_d_h;k_i_h],delu_max,delu_min,state.dt)
if isempty(e_int),e_int = 0; end
    u = K(1)* e + K(2) * e_dot + e_int;
    
    %anti-windup
    stop_e_int = (u>=umax && e>=0 )||(u<=umin && e<=0);
    if ~stop_e_int, e_int = e_int + K(3) *e* dt; end
    