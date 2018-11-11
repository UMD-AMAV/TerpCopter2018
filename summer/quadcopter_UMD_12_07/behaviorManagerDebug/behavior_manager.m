function behavior_manager(obj, event, handles)
% THIS IS THE CALLBACK FUNCTION FOR THE BEHAVIOR MANAGER TIMER. THIS
% CALLBACK FUNCTION UTILIZES THE MISSION PARAMETERS AND FILTERED SENSOR DATA
% TO MANAGE THE EXECUTION AND TRANSITIONING OF THE BEHAVIORS. 
% INPUTS:
%   handles: a structure containing handles to GUI objects
%
% Globals:
%   mission: the structure that contains the mission parameters.
%            (defined in the missionParam.m)
%
% Variables:
%   state: gets the estimated/filtered IMU, Lidar, Px4FLow data.
%          (get_state_estimate.m)
%   
%   mission.bhv : a cell array that holds the current behavior and the
%                 safety behaviors. The current behavior refers to the
%                 current basic mission behavior(takeoff, hover, land,etc).
%                 Depending on the estimated sensor data, safety behaviors
%                 may be activated and take priority over the current
%                 behavior running.
%
% AUTHOR: ZACHARY LACEY
% AFFILIATION : UNIVERSITY OF MARYLAND 
% EMAIL : zlacey@terpmail.umd.edu
%         zlacey1234@gmail.com
%
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
    
    % global structs
    global mission;
    
    % get current state estimate
    state = get_state_estimate(handles);
    %NOTE: state.psi, state.theta and state.phi are in radians
    
    currentAhsCmd = genericAltHeadingSpeedCommand();
    currentBehavior = 1; 
    
    % only executes on the initial first loop
    if mission.config.firstLoop == 1
        disp('Behavior Manager Started')
        % initialize time variables 
        mission.variables.initial_event_time = datetime;  
        mission.variables.behavior_switched_timestamp = datetime;
        mission.variables.behavior_satisfied_timestamp = datetime;
        mission.config.firstLoop = false; % ends the first loop
    end
    
    name = mission.bhv{currentBehavior}.name;
    flag = mission.bhv{currentBehavior}.completion.status;
    
    if flag == true
        disp('completion is true. move to next behavior');
        mission.bhv = pop(mission.bhv);
    else
        disp('checking to see what the current behavior is') 
        
        switch name
            case 'bhv_takeoff'
                 disp('takeoff behavior');
                 %set(handles.takeOff_radio,'Value', true)
                 Z_des = mission.bhv{currentBehavior}.params.desiredAltMeters;
                 [completionFlag] = bhv_takeoff_status(state,Z_des);
            case 'bhv_hover'
                 disp('hover behavior');
                 %set(handles.altitude_control_radio,'Value', true)
                 Z_des = mission.bhv{currentBehavior}.params.desiredAltMeters;
                 t_des = mission.bhv{currentBehavior}.completion.durationSec;
                 [completionFlag] = bhv_hover_status(state,Z_des,t_des);
            case 'bhv_landinghover'
                 disp('hover landing behavior');
                 Z_des = mission.bhv{currentBehavior}.params.desiredAltMeters;
                 t_des = mission.bhv{currentBehavior}.completion.durationSec;
                 [completionFlag] = bhv_hover_status(state,Z_des,t_des);
            case 'bhv_land'
                 disp('land behavior');
                 %set(handles.land_radio,'Value', true)
                 [completionFlag] = bhv_landing_status(state);
            otherwise
                 return;
        end
        % Updates the Completion Flag for the Current Behavior 
        mission.bhv{currentBehavior}.completion.status = completionFlag;
    end            
end

