% parameters
com_port = 'COM3';
baud_rate = 57600;
stick_lim = [100; 100; 100; 100];
trim_lim = [29; 29; 29; 29];
ros_master_ip = '10.1.10.178'; 
%type ifconfig in the terminal of the computer running ros master to get its ip
time_period = 0.1; % period at which the controllers at run