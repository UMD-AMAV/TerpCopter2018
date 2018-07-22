clear; close all; clc;
addpath('./utilities')

vecA = [1 2 1]';
yaw = 0*pi/180;
pitch = 0*pi/180;
roll = 0*pi/180;
angles = [yaw pitch roll]';

% vecB = vectorConversions(vecA, angles, 'inert2imu');
% vecC = vectorConversions(vecB, angles, 'imu2ned');
% vecD = vectorConversions(vecA, angles, 'inert2ned');

vecE = vectorConversions(vecA,angles, 'ned2enu1')
% vecC = vecB - [0 0 9.81]';
% vecD = vectorConversions(vecC, angles, 'inertial2stab');