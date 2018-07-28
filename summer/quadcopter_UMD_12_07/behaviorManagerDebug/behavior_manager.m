function behavior_manager(obj, event, handles)
    %testing purposes
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
            behaviorManagerParam.missionStack{i+1}
        end
        behaviorManagerParam.firstLoop = false;
    end
    
%     behaviorManagerParam.behavior_switched_timestamp;
%     behaviorManagerParam.initial_event_time;
%     current_event_time = datetime;
%     total_elapsed_event_time = seconds(current_event_time - behaviorManagerParam.initial_event_time);
%     current_behavior_elapsed_time = seconds(current_event_time - behaviorManagerParam.behavior_switched_timestamp)
    
    [stackRowNum stackColNum] = size(behaviorManagerParam.missionStack);
    
    for i = 2 : stackColNum
        if behaviorManagerParam.missionStack{i}.active == true
            name = behaviorManagerParam.missionStack{i}.name
            
            
        else
            if behaviorManagerParam.missionStack{currentBehavior}.completion.status == true
                disp('completion is true. move to next behavior');
                behaviorManagerParam.missionStack{currentBehavior} = nextBhv(mission.bhv);
            else
                disp('checking to see what the current behavior is') 
                name = behaviorManagerParam.missionStack{currentBehavior}.name;
            
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
