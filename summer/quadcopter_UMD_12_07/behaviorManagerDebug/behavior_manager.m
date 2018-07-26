function behavior_manager(obj, event, handles)
    %testing purposes
    %addpath('stackFunctions');
    %addpath('messages');
    
    global mission;
    global missionStack;
    currentBehavior = 1;
    
    
    global initial_event_time;
    global behavior_switched_timestamp;     
    
    if isempty(initial_event_time)
        initial_event_time = datetime;
        behavior_switched_timestamp = datetime;
        missionStack = mission.bhv;
    end
    
    behavior_switched_timestamp
    initial_event_time;
    current_event_time = datetime;
    total_elapsed_event_time = seconds(current_event_time - initial_event_time)
    current_behavior_elapsed_time = seconds(current_event_time - behavior_switched_timestamp)
    
%   global handles;
%   disp('behavior_manager is running... ')
%     %  get state estimate from handles
      %  stateEst = getStateEstimate();
      
%     
%     % manage the stack
%     % 
%     %   - check each behavior if it is active
%     %   - check if behaviors have completed
%     %       - if so, replace with next behavior
%     %   - decide which behavior should send command
%       % e.g., behvior format 
%       [ahsCommand, completeFlag] = bhv_takeoff(stateEst)
%     
%     % get ahsCmd from behavior
%     [ahsCmd] = genericAltHeadingSpeedCommand();
%     
%     % publish ahsCommand
%     setAltHeadingSpeedCommand( ahsCmd );

    name = missionStack{currentBehavior}.name;
    type = missionStack{currentBehavior}.type;
    % disp(['Current Behavior:    ', name]);
    
    switch type
        case 'safety'
%            disp('this is a safety behavior');
        case 'mission'
%            disp('this is a mission behavior');           
            switch name
                case 'bhv_takeoff'
                    disp('takeoff behavior');
                    if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
                        missionStack = pop(missionStack);
                    end
                case 'bhv_hover'
                    disp('hover behavior');
                    if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
                        missionStack = pop(missionStack);
                    end
                case 'bhv_landinghover'
                    disp('hover landing behavior');
                    if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
                        missionStack = pop(missionStack);
                    end  
                case 'bhv_land'
                    disp('land behavior');
                    if current_behavior_elapsed_time >= missionStack{currentBehavior}.completion.durationSec
                        missionStack = pop(missionStack);
                        return;
                    end    
        otherwise
            disp('error');
            return;
    end
end


%     mission
%     missionStack = basic_mission;
%     
%     dontQuit = true;
%     currentbehavior = 1;
%     %testing
%     z = 0
%     t = 0
%     yaw_current = 0
%     
%     while(dontQuit)
%         fprintf('Current Behavior: %s \n',missionStack{currentbehavior}.name);
%         
%         n = missionStack{currentbehavior}.name;
%         if missionStack{currentbehavior}.safety == true
%             %execute whatever safety behavior (
%         else
%             if missionStack{currentbehavior}.blocking == true
%                 switch n
%                     case 'takeoff'
%                         z = z + 1     %simulate altitude change
%                         if z >= missionStack{currentbehavior}.altitude.desired
%                             missionStack = pop(missionStack);
%                         end
%                     case 'hover'
%                         z = z + 0.1    %simulate atlitude change
%                         z_tol = abs(z - missionStack{currentbehavior}.altitude.desired)
%                         if z_tol <= 1
%                             t = t + 1
%                             if t > missionStack{currentbehavior}.duration
%                                 missionStack = pop(missionStack);
%                             end
%                         end
%                     case 'point'
%                         yaw_current = yaw_current + 2
%                         yaw_tol = abs(yaw_current - missionStack{currentbehavior}.yaw.desired)
%                         if yaw_tol <= 3
%                             missionStack = pop(missionStack);
%                         end
%                     case 'hold station'
%                         missionStack = pop(missionStack);
%                     case 'land'
%                         missionStack = pop(missionStack);
%                     otherwise
%                         % Safety behavior
%                 end
%                 if isempty(missionStack{1}) == 1
%                     dontQuit = false;
%                 end
%             end
%         end
%     end
%     
% end