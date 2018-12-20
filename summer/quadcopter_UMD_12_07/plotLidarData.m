clear all; close all; clc;
addpath('./results and plots');
kp = 0.41;
kd = 0.098;
ki = 0.02;
k = 1.4;
h_des = 1;
u_max = 1;
data = csvread('altitude_control_data.csv');
cputime = data(:,1)-data(1,1);
z_des = data(:,2);
z_cur = data(:,3);
z_cur_unfiltered = data(:,4);
z_dot = data(:,5);
z_d_dot = data(:,6);
u_actual = data(:,7);
v_z_sp = data(:,8);
v_z_error  = v_z_sp -z_dot; 
v_z_error_dot = -k*z_dot - z_d_dot;

figure(1);
a1= subplot(2,1,1);
plot(cputime, z_cur, 'r-');
hold on
plot(cputime, z_cur_unfiltered,'b-');
plot(cputime, z_des,'k-')
xlabel('Time (sec.)')
ylabel('Altitude(m)')
legend('Filtered Lidar','Raw Lidar', 'desired altitude')
set(gca,'FontSize',16)
grid on

a2 =subplot(2,1,2)
plot(cputime,u_actual,'r-');
xlabel('Time (sec.)')
ylabel('Thrust stick input(norm.)')
ylim=[-1 1];
set(gca,'FontSize',16)
grid on
linkaxes([a1,a2],'xy')

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
plot(cputime(1:end-1),1./diff(cputime),'r-','linewidth',1)
xlabel('Time (sec.)')
ylabel('Frequency (Hz)')
set(gca,'FontSize',16)
grid on


%figure(3);
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
plot(cputime(1:end),v_z_sp,'r-')
hold on;
plot(cputime(1:end),v_z_error,'b-')
xlabel('Time (sec.)')
ylabel('velocity sp,Verror')
set(gca,'FontSize',16)
legend('vzSP','eV= vzSP-zDot');
grid on

figure(5);
plot(cputime,z_dot); hold on; 
plot(cputime,z_cur);
hold on; plot(cputime,z_des,'k-');
xlabel('Time (sec.)');
ylabel('Vz,height');
set(gca,'FontSize',16);
legend('zDot','z');
grid on;


% figure(4);
% plot(u_stick_net(:,1).*129,'ro-','linewidth',2)
% xlabel('Time (sec.)')
% ylabel('u stick net(1)')
% set(gca,'FontSize',16)

figure(6);
plot(cputime, v_z_error_dot);
hold on;
plot(cputime, v_z_error);
hold on 
plot(cputime,u_actual,'r-');
xlabel('Time (sec.)');
ylabel('e_vel,e_vel_dot,u(t)');
set(gca,'FontSize',16);
legend('evel_dot','e_vel','u(t)');
grid on;

figure(7);
plot(cputime,z_dot);
hold on; 
plot(cputime,z_cur);
hold on;
plot(cputime, v_z_error_dot);
hold on;
plot(cputime, v_z_error);
hold on 
plot(cputime,u_actual,'r-');
xlabel('Time (sec.)');
ylabel('zDot,Zcurr,e_vel,e_vel_dot,u(t)');
set(gca,'FontSize',16);
legend('zDot,Z_cur,evel_dot','e_vel','u(t)');
grid on;
