% AUTHOR: MOSS IAN
% AFFILIATION : UNIVERSITY OF MARYLAND 

% Input: 
%   - Z_des: Inputted through GUI by User PRIOR to flight
%   - des_relative_yaw: Inputted through GUI by User PRIOR to flight
%   
% Output:
%   none

%I believe global variables will need to be created for this code to function

%load parameters
%missionParam;
%param;
%addpath('/home/amav/amav/TerpCopter2018/summer/quadcopter_UMD_12_07/virtual_transmitter')


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

%This basic framework should be suitable for running a basic mission,
%however I believe an indexing system for each 'state' using structs for
%parameters like termination requirements would be wise and should not be
%overthought. This may require debugging the current issue that freezes the
%throttle commands of the virtual transmitter when the Altitude Controller
%GUI figure is pressed after it has already been functioned (could apply to
%other GUI objects, but not sure).