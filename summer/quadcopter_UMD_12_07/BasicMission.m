%I believe global variables will need to be created for this code to function

%Initiate Mission
%Begin Take-Off
set(handles.takeOff_radio.Value, 'Value', 1);
disp('Take-Off Enabled')
%If statement uses fact that radio value is set to 0 within takeoff fxn
if (handles.takeOff_radio.Value == 0)
    disp('Take-Off Disabled')
    %Begin Altitude Hold, set to inputted desired height in GUI
    set(handles.h_des_editTextBox,'String',num2str(Z_des));
    set(handles.altitude_control_radio.Value, 'Value', 1);
    disp('Altitude Hold Enabled')
    %After 10 seconds initiate yaw controller
    set(handles.si_des_editTextBox,'String',num2str(des_relative_yaw));
    t = timer('StartDelay',10,'TimerFcn',set(handles.yaw_control_radio.Value, 'Value', 1),'TasksToExecute',1);
    disp('Yaw Hold Enabled')
    delete(t)
    %Checks to see that yaw error is within 1 degree of error
    if (yaw_error >= -0.0174533 && yaw_error <= 0.0174533)
        %Hold yaw and altitude for 10 seconds
        t = timer('StartDelay',10,'TimerFcn',set(handles.yaw_control_radio.Value, 'Value', 0),'TasksToExecute',1);
        disp('Yaw Hold Disabled')
        delete(t)
        %Turn off altitude controller and initiate landing
        set(handles.altitude_control_radio.Value, 'Value', 0);
        disp('Altitude Hold Disabled')
        set(handles.land_radio.Value, 'Value', 1);
        disp('Landing Enabled')
        %Landing controller automatically exits and displays 'land complete'
    end
end  