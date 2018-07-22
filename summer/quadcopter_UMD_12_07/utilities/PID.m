function [u, e_int] = PID(e,e_dot,e_int,K,umax,umin,dt)
%BASIC PID CONTROLLER
if isempty(e_int),e_int = 0; end
    u = K(1)* e + K(2) * e_dot + e_int;
    
    %anti-windup
    stop_e_int = (u>=umax && e>=0 )||(u<=umin && e<=0);
    if ~stop_e_int, e_int = e_int + K(3) *e* dt; end
    