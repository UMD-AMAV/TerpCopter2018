function mission = push(mission, behavior)
global behavior_switched_timestamp;
behavior_switched_timestamp = datetime
[numRow numCol] = size(mission)
for i = numCol: -1: 1
    mission{i + 1} = mission{i};
end
mission{1} = behavior;