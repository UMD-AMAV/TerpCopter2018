function mission = pop(mission)
global behavior_switched_timestamp;
behavior_switched_timestamp = datetime;
[numRow numCol] = size(mission);

if numCol == 1
    mission{1} = {};
else
    mission{1} = {};
    for i = 1 : numCol - 1
        mission{i} = mission{i + 1};
        mission{i + 1} = {};
    end
end