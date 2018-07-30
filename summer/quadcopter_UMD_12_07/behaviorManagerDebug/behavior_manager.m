function behavior_manager(obj, event, handles)
% THIS IS THE CALLBACK FUNCTION FOR THE BEHAVIOR MANAGER TIMER. THIS
% CALLBACK FUNCTION UTILIZES THE MISSION PARAMETERS AND FILTERED SENSOR DATA
% TO MANAGE THE EXECUTION AND TRANSITIONING OF THE BEHAVIORS. 
% INPUTS:
%   handles: a structure containing handles to GUI objects
%
% OUTPUTS:
%   ahsCmd: a command message that contains the desired altitude, heading,
%           forward speed and side speed.
%
% Globals:
%   mission: the structure that contains the mission parameters.
%            (defined in the missionParam.m)
%   behaviorManagerParam: the structure that holds the global variables
%                         used throughout the behavior manager process.
%                         This structure is also where the mission
%                         stack is stored.
%
% Variables:
%   state: gets the estimated/filtered IMU, Lidar, Px4FLow data.
%          (get_state_estimate.m)
%   
%   missionStack: a cell array that holds the current behavior and the
%                 safety behaviors. The current behavior refers to the
%                 current basic mission behavior(takeoff, hover, land,etc).
%                 Depending on the estimated sensor data, safety behaviors
%                 may be activated and take priority over the current
%                 behavior running.
%
%                 missionStack = {[currentBehavior struct] [safetyBehavior1
%                 struct] [safetyBehavior2 struct] ... [safetyBehaviorn
%                 struct]}
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

    %TESTING PURPOSES
    %addpath('stackFunctions');
    %addpath('messages');
    
    disp('Behavior Manager Started')
    
    % global structs
    global mission;
    global behaviorManagerParam;
    
    % get current state estimate
    state = get_state_estimate(handles);
    %NOTE: state.psi, state.theta and state.phi are in radians
    
    currentAhsCmd = genericAltHeadingSpeedCommand();
    currentBehavior = 1; 
    
    % only executes on the initial first loop
    if behaviorManagerParam.firstLoop == 1
        disp('Start firstLoop')
        % initialize time variables 
        behaviorManagerParam.initial_event_time = datetime;  
        behaviorManagerParam.behavior_switched_timestamp = datetime;
        behaviorManagerParam.behavior_satisfied_timestamp = datetime;
        
        % This places the safety behaviors into the missionStack behind the current mission behavior
        behaviorManagerParam.missionStack{currentBehavior} = mission.bhv{1};
        [safetyRowNum safetyColNum] = size(mission.safety);
        for i = 1 : safetyColNum
            behaviorManagerParam.missionStack{i+1} = mission.safety{i};
            % testing
            % behaviorManagerParam.missionStack{i+1}
        end
        behaviorManagerParam.firstLoop = false; % ends the first loop
    end
    
%     behaviorManagerParam.behavior_switched_timestamp;
%     behaviorManagerParam.initial_event_time;
%     current_event_time = datetime;
%     total_elapsed_event_time = seconds(current_event_time - behaviorManagerParam.initial_event_time);
%     current_behavior_elapsed_time = seconds(current_event_time - behaviorManagerParam.behavior_switched_timestamp)
    
    [stackRowNum stackColNum] = size(behaviorManagerParam.missionStack);
    
    name = behaviorManagerParam.missionStack{currentBehavior}.name;
    for i = 2 : stackColNum
        checking_safety_behavior(state,name,i);
        if behaviorManagerParam.missionStack{i}.active == true
            nameSafety = behaviorManagerParam.missionStack{i}.name;
            
            switch nameSafety 
                case 'bhv_lowBattery'
                    disp('run lowBattery function');
                case 'bhv_bhv_opRegion'
                    disp('run opRegion function');
                case 'bhv_maxRoll'
                    disp('run maxRoll function');
                case 'bhv_maxPitch'
                    disp('run mazPitch function');
                otherwise
                    return
            end
        else
            if behaviorManagerParam.missionStack{currentBehavior}.completion.status == true
                disp('completion is true. move to next behavior');
                mission.bhv{behaviorManagerParam.currentBhvIndex} = behaviorManagerParam.missionStack{currentBehavior};
                behaviorManagerParam.missionStack{currentBehavior} = nextBhv(mission.bhv);
            else
                disp('checking to see what the current behavior is') 
            
                switch name
                    case 'bhv_takeoff'
                        disp('takeoff behavior');
                        %set(handles.takeOff_radio,'Value', true)
                        [behaviorActiveFlag] = bhv_takeoff_status(state);
                    case 'bhv_hover'
                        disp('hover behavior');
                        %set(handles.altitude_control_radio,'Value', true)
                        [behaviorActiveFlag] = bhv_hover_status(state);
                    case 'bhv_landinghover'
                        disp('hover landing behavior');
                        [behaviorActiveFlag] = bhv_hover_status(state);
                    case 'bhv_land'
                        disp('land behavior');
                        %set(handles.land_radio,'Value', true)
                        [behaviorActiveFlag] = bhv_landing_status(state);
                        
%                       if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
%                          missionStack = pop(missionStack);
%                           set(handles.land_radio,'Value', false)
%                         
%                           %stops timer
%                           global t_c_behavior_manager
%                           if(t_c_behavior_manager.Running),stop(t_c_behavior_manager);end
%                           delete(t_c_behavior_manager)
%                           clear global t_c_behavior_manager
%                       end   
                    otherwise
                        return;
                end
            end             
        end
    end
%     
%     behaviorTableArray = { name [] behaviorManagerParam.missionStack{currentBehavior}.completion.status;
%                            'lowBattery' behaviorManagerParam.missionStack{2}.active [];
%                            'opRegion' behaviorManagerParam.missionStack{3}.active [];
%                            'maxRoll' behaviorManagerParam.missionStack{4}.active [];
%                            'maxPitch' behaviorManagerParam.missionStack{5}.active []};
%     behaviorTable = array2table(behaviorTableArray, 'VariableNames', {'Name','Active','Complete'})
%                            
%     stateTableArray = {'Roll Angle(Degrees):' rad2deg(state.phi); 
%                        'Pitch Angle(Degrees):' rad2deg(state.theta)};
    
    
    set(handles.edit34,'String', num2str(mission.bhv{1}.completion.status));
    set(handles.edit35,'String', num2str(mission.bhv{2}.completion.status));
    set(handles.edit36,'String', num2str(mission.bhv{3}.completion.status));
    set(handles.edit37,'String', num2str(mission.bhv{4}.completion.status));
    %set(handles.edit38,'String', num2str(mission.bhv{5}.completion.status));
    
    
    set(handles.edit39,'String', num2str(behaviorManagerParam.missionStack{2}.active));
    set(handles.edit41,'String', num2str(behaviorManagerParam.missionStack{3}.active));
    set(handles.edit40,'String', num2str(behaviorManagerParam.missionStack{4}.active));
    set(handles.edit42,'String', num2str(behaviorManagerParam.missionStack{5}.active));
end
%     
%     if current_behavior_elapsed_time >= behaviorManagerParam.missionStack{currentBehavior}.completion.durationSec
%         behaviorManagerParam.missionStack{1} = nextBhv(mission.bhv)
%     end
%     behaviorManagerParam.missionStack{1}
%     
%     
% %   global handles;
% %   disp('behavior_manager is running... ')
% %     %  get state estimate from handles
%       %  stateEst = getStateEstimate();
%       
% %     
% %     % manage the stack
% %     % 
% %     %   - check each behavior if it is active
% %     %   - check if behaviors have completed
% %     %       - if so, replace with next behavior
% %     %   - decide which behavior should send command
% %       % e.g., behvior format 
% %       [ahsCommand, completeFlag] = bhv_takeoff(stateEst)
% %     
% %     % get ahsCmd from behavior
% %     [ahsCmd] = genericAltHeadingSpeedCommand();
% %     
% %     % publish ahsCommand
% %     setAltHeadingSpeedCommand( ahsCmd );
% 
