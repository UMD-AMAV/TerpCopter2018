function [activeFlag] = bhv_hover_status(state)
    disp('bhv_hover_status');
    global behaviorManagerParam
    currentBehavior = 1;
    
    behaviorManagerParam
    toleranceMeters = 0.1;
    Z_des = behaviorManagerParam.missionStack{currentBehavior}.params.desiredAltMeters;
    disp('altitude:')
    state.Z_cur
    
    hoverAltComplete = abs(Z_des - state.Z_cur) < toleranceMeters
    if hoverAltComplete
        disp('hover alt satisfied');
        current_event_time = datetime;
        activeFlag = 0;
    else
        disp('hover alt not satisfied');
        current_event_time = datetime;
        behaviorManagerParam.behavior_satisfied_timestamp = datetime; 
    end
    elapsed_satisfied_time = seconds(current_event_time - behaviorManagerParam.behavior_satisfied_timestamp)
    
    if elapsed_satisfied_time >= behaviorManagerParam.missionStack{currentBehavior}.completion.durationSec
        disp('hover is complete')
        behaviorManagerParam.missionStack{currentBehavior}.completion.status = true;
        activeFlag = 0;
        return;
    end
    
    activeFlag = 1;
end