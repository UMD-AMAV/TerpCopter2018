global mission
global behaviorManagerParam

behaviorManagerParam.firstLoop = true;
behaviorManagerParam.currentBhvIndex = 1;

% Define overall mission configuration
mission.config.refLatDeg = 00.00000;
mission.config.refLongDeg = 00.00000;
mission.config.rosMasterIP = '192.168.1.3';
mission.config.pitchTrim = 0000;
mission.config.rollTrim = 0000;
mission.config.yawTrim = 0000;
mission.config.throttleTrim = 0000;

%%%%%%%%%%%%%%%%%% SAFETY BEHAVIORS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ind = 0;

% low battery 
ind = ind+1;
mission.safety{ind}.name = 'bhv_lowBattery';
mission.safety{ind}.type = 'safety';
mission.safety{ind}.priority = 1.0;
mission.safety{ind}.params.minVoltage = 10.0;
mission.safety{ind}.active = false;


ind = ind+1;
mission.safety{ind}.name = 'bhv_opRegion';
mission.safety{ind}.type = 'safety';
mission.safety{ind}.priority = 1.0;
mission.safety{ind}.active = false;
mission.safety{ind}.params.minNorthtMeters = 0.0;
mission.safety{ind}.params.maxNorthMeters = 10.0;
mission.safety{ind}.params.minEastMeters = 0.0;
mission.safety{ind}.params.maxEastMeters = 10.0;
mission.safety{ind}.params.minDownMeters = -10.0;
mission.safety{ind}.params.maxDownMeters = 0.0;

ind = ind+1;
mission.safety{ind}.name = 'bhv_maxRoll';
mission.safety{ind}.type = 'safety';
mission.safety{ind}.priority = 1.0;
mission.safety{ind}.active = false;
mission.safety{ind}.params.maxRollLimitDegrees = 20;

% Define mission behaviors
ind = 0;

ind = ind+1;
mission.bhv{ind}.name = 'bhv_takeoff';
mission.bhv{ind}.type = 'mission';
mission.bhv{ind}.params.desiredAltMeters = 0.6;
mission.bhv{ind}.params.timeoutSec= 60.0;
mission.bhv{ind}.safetyPriority = false;
mission.bhv{ind}.completion.type = 'stateValue';
mission.bhv{ind}.completion.status = false;
mission.bhv{ind}.completion.threshold = 0.1;    % tolerance
mission.bhv{ind}.blocking = false;
%testing
mission.bhv{ind}.completion.durationSec = 9.95;   % 10 seconds

ind = ind+1;
mission.bhv{ind}.name = 'bhv_hover';
mission.bhv{ind}.type = 'mission';
mission.bhv{ind}.params.desiredAltMeters = 1.0;
mission.bhv{ind}.safetyPriority = false;
mission.bhv{ind}.completion.type = 'time';
mission.bhv{ind}.completion.durationSec = 5.95;    % 6 seconds
mission.bhv{ind}.completion.status = false;
mission.bhv{ind}.blocking = false;

ind = ind+1;
mission.bhv{ind}.name = 'bhv_landinghover';
mission.bhv{ind}.type = 'mission';
mission.bhv{ind}.params.desiredAltMeters = 0.5;
mission.bhv{ind}.safetyPriority = false;
mission.bhv{ind}.completion.type = 'time';
mission.bhv{ind}.completion.durationSec = 2.95;     % 3 seconds
mission.bhv{ind}.completion.status = false;
mission.bhv{ind}.blocking = false;

ind = ind+1;
mission.bhv{ind}.name = 'bhv_land';
mission.bhv{ind}.type = 'mission';
mission.bhv{ind}.params.maxDescentRateMps = 0.2;
mission.bhv{ind}.params.desiredAltMeters = 0.25;
mission.bhv{ind}.safetyPriority = false;
mission.bhv{ind}.completion.type = 'stateValue';
mission.bhv{ind}.completion.threshold = 0.1;
mission.bhv{ind}.completion.status = false;
mission.bhv{ind}.blocking = false;
%testing
mission.bhv{ind}.completion.durationSec = 4.95;     % 5 seconds




% Testing Purposes 
% mission.bhv{1}
% mission.bhv{1}.params
% mission.bhv{1}.completion
% 
% mission.bhv{2}
% mission.bhv{2}.params
% mission.bhv{2}.completion
% 
% mission.bhv{3}
% mission.bhv{3}.params
% mission.bhv{3}.completion
% 
% mission.bhv{4}
% mission.bhv{4}.params
% mission.bhv{4}.completion

% mission.safety{1}


% mission
% mission.config
% mission.safety
% mission.bhv