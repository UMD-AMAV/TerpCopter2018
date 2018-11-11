function [activeFlag] = bhv_landing_status(state)
    disp('bhv_landing_status');
    global behaviorManagerParam
    currentBehavior = 1;
    
    disp(state.Z_cur);
    if state.Z_cur <= behaviorManagerParam.missionStack{currentBehavior}.params.desiredAltMeters
        disp('land complete');
        
        activeFlag = 1;
        %stops timer
        global t_c_behavior_manager
        if(t_c_behavior_manager.Running),stop(t_c_behavior_manager);end
        delete(t_c_behavior_manager)
        clear global t_c_behavior_manager
        disp('Done')
    end
    activeFlag = 0;
end