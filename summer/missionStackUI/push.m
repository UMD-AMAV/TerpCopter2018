function mission = push(mission, missionState, behavior)
   if mission{1,missionState} == 0
       mission{1,missionState} = behavior;
   else
       mission{end + 1,missionState} = behavior;
   end
end



