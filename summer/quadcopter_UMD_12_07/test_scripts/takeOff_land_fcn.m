function [u_stick_cmd,takeOffComplete,u_prev_thr] = takeOff_land_fcn(state,handles,u_stick_cmd,params,u_prev_thr,flag)

if flag == 0
  %do take off
takeOffparams.Gain = 1;
takeOffparams.Vsp = 0.2;
takeOffparams.Z_des =1;%m
takeOffparams.eps  = 0.1;

if 0
    %logic for aborting take off goes here
    
    disp('vehicle already in air');
    disp('aborting takeoff');
    handles.takeOff_radio.Value = 0;
    takeOffComplete = 0;
    u_prev_thr = [];
    return;
else    
  %disp('takoff function running');
   disp(state.Z_dot);  
  %if takeOffComplete, switch on altitude control and return
  takeOffComplete = abs(takeOffparams.Z_des - state.Z_cur)<takeOffparams.eps;
  if takeOffComplete
      set(handles.h_des_editTextBox,'String',num2str(takeOffparams.Z_des));
      handles.altitude_control_radio.Value = 1;
      handles.takeOff_radio.Value = 0;
      u_prev_thr = [];
      return;
  end
      
  %velocity control loop
  v_error = takeOffparams.Vsp - state.Z_dot;
  u_dot = takeOffparams.Gain*v_error;
  
  if isempty( u_prev_thr),u_prev_thr = -1;end
  u = u_prev_thr + u_dot*state.dt;
  u_prev_thr = u;
  if u>params.umax_throttle || u<-params.umax_throttle, u = u*params.umax_throttle/abs(u);end
  
  %calculate thrust
  u_stick_cmd(1)= u;
  u_stick_cmd(1) = max(-params.umax_throttle, min(params.umax_throttle,u_stick_cmd(1)));
end

elseif flag == 1
 %do land
    
landparams.Gain = 2;
landparams.Z_des =0.2;%m
landparams.eps  = 0.05;

if  state.Z_cur <=landparams.Z_des  
    %logic for aborting land goes here
    %if throttle stick is not at -1, abort 
    disp('vehicle already on ground');
    handles.land_radio.Value = 0;
    takeOffComplete = NaN;
else    
   disp('land function running');
   disp(state.Z_dot);  
  %get the last stick position before land_fcn was called 
  if isempty(u_prev_thr)
     u_prev_thr = get(handles.pax(1),'YData');
   end
  %velocity control loop
   v_error = landparams.Vsp - state.Z_dot;
  %u_dot = max(-0.2,0.1*(landparams.Z_des - state.Z_cur)); 
  u_dot = landparams.Gain*v_error;
  u = u_prev_thr + u_dot*state.dt;
  u_prev_thr = u;
  if u>params.umax_throttle || u<-params.umax_throttle, u = u*params.umax_throttle/abs(u);end
  
  %calculate thrust
  u_stick_cmd(1)= u;
  u_stick_cmd(1) = max(-params.umax_throttle, min(params.umax_throttle,u_stick_cmd(1)))
  
  landComplete = abs(landparams.Z_des - state.Z_cur)<landparams.eps;
  if landComplete
      %TODO: if land completes, kill motors
       u_stick_cmd(1) = -params.umax_throttle;
       handles.land_radio.Value = 0;
  end
  
  %switch off altitude control if running
  handles.altitude_control_radio.Value = 0;
  %switch off takeoff if running
  handles.takeOff_radio.Value = 0;
  takeOffComplete = NaN;
end

end
