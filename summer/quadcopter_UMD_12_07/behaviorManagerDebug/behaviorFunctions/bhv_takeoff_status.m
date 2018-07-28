function [activeFlag] = bhv_takeoff_status(state)
   disp('bhv_takeoff_status');
   global behaviorManagerParam
   currentBehavior = 1;
   
   toleranceMeters  = 0.1;
   Z_des = behaviorManagerParam.missionStack{1}.params.desiredAltMeters;
   disp('altitude:')
   state.Z_cur
   
   %if takeOffComplete, switch on altitude control and return
   takeOffComplete = abs(Z_des - state.Z_cur)<toleranceMeters;
   if takeOffComplete
      behaviorManagerParam.missionStack{currentBehavior}.completion.status = true;
      activeFlag = 0;
      return;
   end
   
   activeFlag = 1;
end