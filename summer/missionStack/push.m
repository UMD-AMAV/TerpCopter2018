function mission = push(mission, missionState, numRow, behavior)
   if mission{1,missionState} == 0
       mission{1,missionState} = behavior;
   else
       loopCount = 0
       for i = numRow: -1: 1
           i
           loopCount = loopCount + 1 
           mission{i + 1, missionState} = mission{i, missionState}
       end
       mission{1, missionState} = behavior;
   end




