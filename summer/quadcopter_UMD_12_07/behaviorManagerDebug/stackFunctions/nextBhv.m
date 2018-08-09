function missionStack = nextBhv(missionBehavior)
global behaviorManagerParam;
behaviorManagerParam.behavior_switched_timestamp = datetime

[numRow numCol] = size(missionBehavior)

missionStack(1) = missionBehavior{1 + behaviorManagerParam.currentBhvIndex}
behaviorManagerParam.nextBhvCounter = behaviorManagerParam.currentBhvIndex + 1;





