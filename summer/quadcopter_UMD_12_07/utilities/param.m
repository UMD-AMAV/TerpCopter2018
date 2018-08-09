% parameters
params.com_port = 'COM4';
params.baud_rate = 57600;
params.stick_lim = [100; 100; 100; 100];
params.trim_lim = [29; 29; 29; 29];
params.ros_master_ip = '10.1.10.248'; % type ifconfig in the terminal 
                                      % of the computer running ros master to get its ip
                                      
params.time_period = 0.1; % intervals at which timer callback function is executed
params.umax_throttle = 1; %
params.umax_rollPitch = 0.5;
params.v_z_max = 3;
params.m_quad = 0.359;%kg
params.m_battery1 = 0.116;%kg
params.m_net = params.m_quad + params.m_battery1;
params.g = 9.81;%m/s^2
params.tilt_max = deg2rad(45);%max allowed tilt angle
                              % tilt angle  = acos{cos(theta)*cos(phi)}
params.v_z_error_int_takeOff = []; %variables to accumulate integral error
params.v_z_error_int_land = [];
params.takeOffHeight = 0.5;%m   %takeoff controller will take the quad to this height and hover
params.takeOffSpeed = 0.4;%m/s %vertical takeoff speed 
params.landCompleteHeight = 0.25;%m height at which the quad can be asumed to have landed
params.landSpeed = 0.2;%m/s %vertical landing speed
