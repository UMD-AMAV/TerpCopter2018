function [completionFlag] = bhv_landing_status(state, handles,param,completion)
    disp('bhv_landing_status');
    currentBehavior = 1;
    
    disp(state.Z_cur);
    if state.Z_cur <= param.desiredAltMeters
        disp('land complete');
        set(handles.land_radio,'Value', false);
        completionFlag = 1;
        disp('Done')
    end
    completionFlag = 0;
end