function checking_safety_behavior(state,behaviorName,Index)
% THIS FUNCTION TAKES THE ESTIMATED/FILTERED IMU,LIDAR,CAMERA,PX4FLOW DATA
% AND DETERMINES WHETHER A SAFETY BEHAVIOR IS NEEDED THROUGH VARIOUS SAFETY 
% CONDITIONS. WHEN SAFETY CONDITIONS ARE VIOLATED, A CORRESPONDING SAFETY 
% BEHAVIOR IS ACTIVATED. SAFETY BEHAVIORS ARE DEACTIVATED ONCE THE SAFETY
% CONDITIONS ARE NOT VIOLATED.
% 
% INPUTS:
%   state: gets the estimated/filtered IMU, Lidar, Px4FLow data.
%          (get_state_estimate.m)
%   behaviorName: gets the behaviors name NOTE: usually the current
%                 behavior name('name' in the behavior_manager.m)
%   Index: just refers to the index 'i' in the main for loop in
%          behavior_manager.m
% 
% OUTPUT:
%   none
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

disp('Checking Safety Behaviors Started'); 
global behaviorManagerParam


disp(behaviorManagerParam.missionStack{Index}.name);
switch Index
    case 2
        disp('low battery is being checked');
    case 3
        disp('operation region is being checked');
    case 4
        disp('maximum roll is being checked');
        % Maximum roll safety
        if abs(state.phi) >= behaviorManagerParam.missionStack{Index}.params.maxRollLimitRadians
            disp('Maximum Roll exceeded');
            behaviorManagerParam.missionStack{Index}.active = true
        else
            disp('Roll is good');
            behaviorManagerParam.missionStack{Index}.active = false
        end
    case 5
        disp('maximum pitch is being checked');
        if abs(state.theta) >= behaviorManagerParam.missionStack{Index}.params.maxPitchLimitRadians
            disp('Maximum Pitch exceeded');
            behaviorManagerParam.missionStack{Index}.active = true
        else
            disp('Pitch is good');
            behaviorManagerParam.missionStack{Index}.active = false
        end
    case 6
        disp('obstacle');
    otherwise
        return
end
disp('Checking Safety Behavior Ended');
end
