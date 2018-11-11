function newMissionBehavior = nextBhv(currentMissionBehavior)
% THIS FUNCTION ASSIGNS THE NEXT BEHAVIOR INTO THE MISSION STACK.
%
% INPUTS:
%   missionBehavior: obtains the behavior from the mission.bhv cell array
%
% OUTPUT:
%   missionStack: places the behavior into the missionStack cell array in
%                 behavior_manager.m
%
% AUTHOR: ZACHARY LACEY
% AFFILIATION : UNIVERSITY OF MARYLAND 
% EMAIL : zlacey@terpmail.umd.edu
%         zlacey1234@gmail.com
%
% THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THE GPLv3 LICENSE
% THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. ANY USE OF
% THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
% PROHIBITED.
%  
% BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO
% BE BOUND BY THE TERMS OF THIS LICENSE. THE LICENSOR GRANTS YOU THE RIGHTS
% CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH TERMS AND
% CONDITIONS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global mission
mission.variables.behavior_switched_timestamp = datetime

[numRow numCol] = size(CurrentMissionBehavior)

missionStack(1) = missionBehavior{1 + behaviorManagerParam.currentBhvIndex}
behaviorManagerParam.currentBhvIndex = behaviorManagerParam.currentBhvIndex + 1;
end





