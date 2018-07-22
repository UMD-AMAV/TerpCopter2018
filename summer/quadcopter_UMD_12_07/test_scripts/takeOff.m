function [u_stick_cmd,takeOffComplete,u_prev] = takeOff_land_fcn(state,handles,u_stick_cmd,params,u_prev,flag)

if flag == 0
    %do take off
takeOffparams.Gain = 0.4;
takeOffparams.Vsp = 0.4;
takeOffparams.Z_des =1;%m
takeOffparams.eps  = 0.1;

%get throttle stick position
% u_stick_thr_pos = handles.pax(1).YData;
if 0
    %logic for aborting take off goes here
    %if throttle stick is not at -1, abort 
    disp('vehicle already in air');
    disp('aborting takeoff');
    handles.takeOff_radio.Value = 0;
    takeOffComplete = 0;
    return;
else    
  %disp('takoff function running');
   disp(state.Z_cur);  
  %if takeOffComplete, switch on altitude control and return
  takeOffComplete = abs(takeOffparams.Z_des - state.Z_cur)<takeOffparams.eps;
  if takeOffComplete
      set(handles.h_des_editTextBox,'String',num2str(takeOffparams.Z_des));
      handles.altitude_control_radio.Value = 1;
      handles.takeOff_radio.Value = 0;
      u_prev = [];
      return;
  end
      
  %velocity control loop
  v_error = takeOffparams.Vsp - state.Z_dot;
  u_dot = takeOffparams.Gain*v_error;
  if isempty( u_prev),u_prev = -1;end
   u = u_prev + u_dot*state.dt;
  u_prev = u;
  if u>params.umax_throttle || u<-params.umax_throttle, u = u*params.umax_throttle/abs(u);end
  
  %calculate thrust
  u_stick_cmd(1)= u/(cos(state.theta)*cos(state.phi));
  u_stick_cmd(1) = max(-params.umax_throttle, min(params.umax_throttle,u_stick_cmd(1)));
end

elseif flag == 1
    %do land
    
landparams.Gain = 0.4;
landparams.Vsp = 0.4;
landparams.Z_des =1;%m
landparams.eps  = 0.1;

end
