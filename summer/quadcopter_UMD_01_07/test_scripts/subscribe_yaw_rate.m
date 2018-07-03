function subscribe_yaw_rate()
% test function. No use in main code
global yaw_a
clc;
rosshutdown
rosinit('10.1.10.219');
yaw_a = rossubscriber('/yawtopic',@altitude_control,...
    'BufferSize',1);

%% pause();****DON'T DELETE*******
% ISSUE: subscriber subscribes to yawtopic data
%only for pause(x) seconds 
% this is beacause once the function ends, yaw_a
% which is local to the function, goes out of scope
% making yaw_a global solves the issue
% scandata = receive(yaw_a,10)
end