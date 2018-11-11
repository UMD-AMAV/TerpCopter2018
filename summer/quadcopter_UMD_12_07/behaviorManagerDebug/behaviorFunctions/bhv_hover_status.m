function [completionFlag] = bhv_hover_status(state, Z_des, t_des)
    disp('bhv_hover_status');
    global mission
    
    toleranceMeters = 0.1;
    disp('altitude:')
    state.Z_cur;
    
    hoverAltComplete = abs(Z_des - state.Z_cur) < toleranceMeters;
    if hoverAltComplete
        disp('hover alt satisfied');
        current_event_time = datetime;
    else
        disp('hover alt not satisfied');
        current_event_time = datetime;
        mission.variables.behavior_satisfied_timestamp = datetime; 
    end
    elapsed_satisfied_time = seconds(current_event_time - mission.variables.behavior_satisfied_timestamp);
    
    if elapsed_satisfied_time >= t_des
        disp('hover is complete')
        completionFlag = 1;
        return;
    end
    completionFlag = 0;
end