global mission

% Define overall mission configuration
mission.config.refLatDeg = 00.00000;
mission.config.refLongDeg = 00.00000;
mission.config.rosMasterIP = '192.168.1.3';
mission.config.pitchTrim = 0000;
mission.config.rollTrim = 0000;
mission.config.yawTrim = 0000;
mission.config.throttleTrim = 0000;
mission.config.firstLoop = true;
mission.config.currentBhvIndex = 1;

% Define mission behaviors
ind = 0;

%Safety behaviors on top that dont get popped

%Behavior 1 (mission.bhv{1})
ind = ind+1;
mission.bhv{ind}.name = 'bhv_takeoff';
mission.bhv{ind}.params.desiredAltMeters = .5;
mission.bhv{ind}.params.timeoutSec= 60.0;
mission.bhv{ind}.completion.status = false;     % completion flag
mission.bhv{ind}.completion.threshold = 0.1;    % tolerance

%Behavior 2 (mission.bhv{2})
ind = ind+1;
mission.bhv{ind}.name = 'bhv_hover';
mission.bhv{ind}.params.desiredAltMeters = 1.0;
mission.bhv{ind}.completion.durationSec = 9.95; % 10 seconds
mission.bhv{ind}.completion.status = false;     % completion flag

%Behavior 3 (mission.bhv{3})
ind = ind+1;
mission.bhv{ind}.name = 'bhv_landinghover';
mission.bhv{ind}.params.desiredAltMeters = 0.5;
mission.bhv{ind}.completion.type = 'time';
mission.bhv{ind}.completion.durationSec = 2.95; % 3 seconds
mission.bhv{ind}.completion.status = false;     % completion flag

%Behavior 4 (mission.bhv{4})
ind = ind+1;
mission.bhv{ind}.name = 'bhv_land';
mission.bhv{ind}.params.maxDescentRateMps = 0.2;
mission.bhv{ind}.params.desiredAltMeters = 0.25;
mission.bhv{ind}.completion.threshold = 0.1;
mission.bhv{ind}.completion.status = false;