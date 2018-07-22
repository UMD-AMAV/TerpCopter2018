 clear all; close all; clc;
 addpath('./results and plots');
kp = 0.5;
kd = 0;
ki = 0.0;
h_des = 1.5;
u_max = 1;
data = csvread('altitude_control_data_test_12_07.csv');
cputime = data(:,1)-data(1,1);
z_des = data(:,2);
z_cur = data(:,3);
z_cur_unfiltered = data(:,4);
z_dot = data(:,5);
z_d_dot = data(:,6);
u_actual = data(:,7);
v_z_sp = data(:,8);


figure(1);
subplot(2,1,1)
plot(cputime, z_cur, 'ro-');
hold on
plot(cputime, z_cur_unfiltered,'bo-');
plot(cputime, z_des,'ko-')
xlabel('Time (sec.)')
ylabel('Altitude(m)')
legend('Filtered Lidar','Raw Lidar', 'desired altitude')
set(gca,'FontSize',16)
grid on

subplot(2,1,2)
plot(cputime,u_actual,'ro-');
xlabel('Time (sec.)')
ylabel('Thrust stick input(norm.)')
set(gca,'FontSize',16)
grid on

% plot(cputime, z_dot,'bo-');
% xlabel('Time (sec.)')
% ylabel('vertical velocity (m/s)')
% set(gca,'FontSize',16)
% grid on

% subplot(3,1,3)
% plot(cputime, z_d_dot,'bo-');
% xlabel('Time (sec.)')
% ylabel('vertical acc (m/s^2)')
% set(gca,'FontSize',16)
% grid on

figure(2);
plot(cputime(1:end-1),1./diff(cputime),'ro-','linewidth',1)
xlabel('Time (sec.)')
ylabel('Frequency (Hz)')
set(gca,'FontSize',16)
grid on


figure(3);
% delu_postProcess = kp*h_error + kd*del_e_h+ki*e_int;
% delu_postProcess = max(-u_max,min(u_max,delu_postProcess));
% plot(cputime,delu_postProcess*129,'bo-','linewidth',2)
% plot(cputime,u_actual,'ro-');
% xlabel('Time (sec.)')
% ylabel('Throttle stick input (norm.)')
% set(gca,'FontSize',16)
% %hold on;
% % legend('delu postprocess','u actual');
% grid on

figure(4);
plot(cputime(1:end),v_z_sp,'ro-')
xlabel('Time (sec.)')
ylabel('velocity sp')
set(gca,'FontSize',16)
grid on

% figure(4);
% plot(u_stick_net(:,1).*129,'ro-','linewidth',2)
% xlabel('Time (sec.)')
% ylabel('u stick net(1)')
% set(gca,'FontSize',16)
