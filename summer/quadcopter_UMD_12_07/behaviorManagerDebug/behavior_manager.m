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
    
    currentBehavior = 1;
    
    if behaviorManagerParam.firstLoop == 1
        disp('Start firstLoop')
        % initialize time variables 
        behaviorManagerParam.initial_event_time = datetime;  
        behaviorManagerParam.behavior_switched_timestamp = datetime;
        
        % This places the safety behaviors into the missionStack behind the current mission behavior
        behaviorManagerParam.missionStack{1} = mission.bhv{1};
        [safetyRowNum safetyColNum] = size(mission.safety);
        for i = 1 : safetyColNum
            behaviorManagerParam.missionStack{i+1} = mission.safety{i};
            % testing
            behaviorManagerParam.missionStack{i+1}
        end
        behaviorManagerParam.firstLoop = false;
    end
    
    behaviorManagerParam.behavior_switched_timestamp;
    behaviorManagerParam.initial_event_time;
    current_event_time = datetime;
    total_elapsed_event_time = seconds(current_event_time - behaviorManagerParam.initial_event_time);
    current_behavior_elapsed_time = seconds(current_event_time - behaviorManagerParam.behavior_switched_timestamp)
    
    [stackRowNum stackColNum] = size(behaviorManagerParam.missionStack)
    
    for i = 2 : stackColNum
        % checking if a safety behavior has priority
        if behaviorManagerParam.missionStack{currentBehavior}.safetyPriority == true    
            disp('A safety behavior has taken priority');
        elseif behaviorManagerParam.missionStack{currentBehavior}.completion.status == false
            disp('checking')
            
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
%     name = missionStack{currentBehavior}.name
%     type = missionStack{currentBehavior}.type;
%     % disp(['Current Behavior:    ', name]);
%     
%     %%%%% NOTE: The missionStack = pop(missionStack) command should
%     %%%%% probably be done within the behavior functions.
%     
%     switch type
%         case 'safety'
% %            disp('this is a safety behavior');
%         case 'mission'
% %            disp('this is a mission behavior');           
%             switch name
%                 case 'bhv_takeoff'
%                     disp('takeoff behavior');
%                     set(handles.takeOff_radio,'Value', true)
%                     
%                     if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
%                         missionStack = pop(missionStack);
%                         set(handles.takeOff_radio,'Value', false)
%                     end
%                 case 'bhv_hover'
%                     disp('hover behavior');
%                     set(handles.altitude_control_radio,'Value', true)
%                     
%                     if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
%                         missionStack = pop(missionStack);
%                         set(handles.altitude_control_radio,'Value', false)
%                     end
%                 case 'bhv_landinghover'
%                     disp('hover landing behavior');
%                     if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
%                         missionStack = pop(missionStack);
%                     end  
%                 case 'bhv_land'
%                     disp('land behavior');
%                     set(handles.land_radio,'Value', true)
%                     
%                     if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
%                         missionStack = pop(missionStack);
%                         set(handles.land_radio,'Value', false)
%                         
%                         %stops timer
%                         global t_c_behavior_manager
%                         if(t_c_behavior_manager.Running),stop(t_c_behavior_manager);end
%                         delete(t_c_behavior_manager)
%                         clear global t_c_behavior_manager
%                     end    
%         otherwise
%             disp('error');
%             return;
%     end
% end
% 
% 
% %     mission
% %     missionStack = basic_mission;
% %     
% %     dontQuit = true;
% %     currentbehavior = 1;
% %     %testing
% %     z = 0
% %     t = 0
% %     yaw_current = 0
% %     
% %     while(dontQuit)
% %         fprintf('Current Behavior: %s \n',missionStack{currentbehavior}.name);
% %         
% %         n = missionStack{currentbehavior}.name;
% %         if missionStack{currentbehavior}.safety == true
% %             %execute whatever safety behavior (
% %         else
% %             if missionStack{currentbehavior}.blocking == true
% %                 switch n
% %                     case 'takeoff'
% %                         z = z + 1     %simulate altitude change
% %                         if z >= missionStack{currentbehavior}.altitude.desired
% %                             missionStack = pop(missionStack);
% %                         end
% %                     case 'hover'
% %                         z = z + 0.1    %simulate atlitude change
% %                         z_tol = abs(z - missionStack{currentbehavior}.altitude.desired)
% %                         if z_tol <= 1
% %                             t = t + 1
% %                             if t > missionStack{currentbehavior}.duration
% %                                 missionStack = pop(missionStack);
% %                             end
% %                         end
% %                     case 'point'
% %                         yaw_current = yaw_current + 2
% %                         yaw_tol = abs(yaw_current - missionStack{currentbehavior}.yaw.desired)
% %                         if yaw_tol <= 3
% %                             missionStack = pop(missionStack);
% %                         end
% %                     case 'hold station'
% %                         missionStack = pop(missionStack);
% %                     case 'land'
% %                         missionStack = pop(missionStack);
% %                     otherwise
% %                         % Safety behavior
% %                 end
% %                 if isempty(missionStack{1}) == 1
% %                     dontQuit = false;
% %                 end
% %             end
% %         end
% %     end
% %     
% % end