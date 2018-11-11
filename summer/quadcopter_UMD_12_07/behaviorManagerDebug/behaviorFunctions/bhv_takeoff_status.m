function [completionFlag] = bhv_takeoff_status(state, param, completion)
   disp('bhv_takeoff_status');
   
   %if takeOffComplete, switch on altitude control and return
   takeOffComplete = state.Z_cur > param.desiredAltMeters;
   if takeOffComplete
      completionFlag = 1;
      return;
   end
   completionFlag = 0;
end