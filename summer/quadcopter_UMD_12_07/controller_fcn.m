function controller_fcn(obj,evnt,handles,params)
% THIS IS THE CALLBACK FUNCTION FOR THE MATLAB TIMER OBJECT. IT UPDATES 
% STATE MEASUREMENTS ON THE GUI AND CALLS THE YAW, ALTITUDE AND 
%FORWARD-CRAB-SPEED CONTROLLERS. 
%INPUTS:
%   handles: a structure containing handles to GUI objects
%   parmas: parameters defined in param.m file.
%
% OUTPUT:
%   none
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

%disp('executing controller_fcn');
persistent v_z_error_int v_z_error_int_takeOff v_z_error_int_land;
persistent v_forward_error_int v_crab_error_int;
persistent u_stick_thr_cur u_prev_thr_takeOff u_prev_thr_land ; 

%% get current state estimate
state = get_state_estimate(handles);
%NOTE: state.psi, state.theta and state.phi are in radians


u_stick_cmd(1:4) = NaN;
trim(1:4) = NaN;

%% if takeoff button is depressed run takeoff function
if(handles.takeOff_radio.Value == 1)
    params.v_z_error_int_takeOff = v_z_error_int_takeOff;
   [u_stick_cmd,v_z_error_int_takeOff]= takeOff(state,handles,u_stick_cmd,params);
else 
    %reset persistent variables
    v_z_error_int_takeOff =[];
end

%% if land button is depressed run land function
if(handles.land_radio.Value == 1)
    params.v_z_error_int_land = v_z_error_int_land;
   [u_stick_cmd,v_z_error_int_land]= land(state,handles,u_stick_cmd,params);
else 
    %reset persistent variables
    v_z_error_int_land =[];
end

%% if yaw control button is on run yaw controller
if(handles.yaw_control_radio.Value == 1)
u_stick_cmd = yawController(state,handles,u_stick_cmd);
end    
   
%% if altitude control button is on run altitude control
if handles.altitude_control_radio.Value==1
   %set the initial throttle stick position to the current stick position
   %get current stick position from GUI
   if isempty(u_stick_thr_cur)
       u_stick_thr_cur = get(handles.pax(1),'YData');
   end
   params.v_z_error_int = v_z_error_int;
   [u_stick_cmd,v_z_error_int]= altitudeController(state,handles,u_stick_cmd,params,u_stick_thr_cur);
else 
    %reset persistent variables
    v_z_error_int =[];
    u_stick_thr_cur = [];
end

%% If forward_crab_speed_radio button is on run forward_crab_speed control
if handles.forward_crab_speed_radio.Value==1
  params.v_forward_error_int = v_forward_error_int;
  params.v_crab_error_int = v_crab_error_int;
  [u_stick_cmd,v_forward_error_int, v_crab_error_int]= ...
  forwardCrabSpeedController(state,handles,u_stick_cmd,params); 
else
    %reset integral term
    v_forward_error_int =[];
    v_crab_error_int =[];
end

%% send stick commands to transmitter
if (u_stick_cmd(1) ==NaN && u_stick_cmd(2) ==NaN && u_stick_cmd(3) ==NaN...
    && u_stick_cmd(4) ==NaN && trim(1) == NaN && trim(2) == NaN && trim(3) == NaN &&...
    trim(4) == NaN)
    %disp('exiting controller fcn');
    return;
else
     send_stick_cmd(u_stick_cmd,trim,handles);
end
end

%%
%   plot yaw error
%   tlag = 200;
%   abs_t = eval([int2str(imu_msg.Header.Stamp.Sec) '.' ...
%   int2str(imu_msg.Header.Stamp.Nsec)]);
%   if isempty(t0), t0 = abs_t; end
%   t = abs_t-t0;
%   figure(2);
%   plot(t,rad2deg(yaw_error),'r.'); set(gca,'xlim',[max(t-tlag,0) max(t,1)])
%   set(gca,'ylim',[-180 180]);
%   hold on, ylabel('Yaw error '); grid on;

 