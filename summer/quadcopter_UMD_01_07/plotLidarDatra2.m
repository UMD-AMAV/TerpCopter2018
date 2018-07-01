  clear all; close all; clc;
kp = 0.5;
kd = 0;
ki = 0.0;
h_des = 1.5;
u_max = 1;
data = csvread('altitude_control_data.csv');
cputime = data(:,1)-data(1,1);
z_cur = data(:,2);
z_cur_unfiltered = data(:,3);
z_dot = data(:,4);
z_d_dot = data(:,5);
u_actual = data(:,6);
v_z_sp = data(:,7);

% e_int =zeros(length(h_error),1);
% for i = 2:length(h_error)
%     e_int(i) = e_int(i-1) + h_error(i);
% end


figure(1);
subplot(3,1,1)
plot(cputime, z_cur, 'ro-');
hold on
plot(cputime, z_cur_unfiltered,'bo-');
plot(cputime, ones(size(cputime))*h_des,'k--')
xlabel('Time (sec.)')
ylabel('Altitude (m)')
legend('Filtered Lidar','Raw Lidar', 'desired altitude')
set(gca,'FontSize',16)

subplot(3,1,2)
plot(cputime, z_dot,'bo-','linewidth',1);
xlabel('Time (sec.)')
ylabel('vertical velocity ')
set(gca,'FontSize',16)

subplot(3,1,3)
plot(cputime, z_d_dot,'bo-','linewidth',1);
xlabel('Time (sec.)')
ylabel('vertical acceleration')
set(gca,'FontSize',16)

figure(2);
plot(cputime(1:end-1),1./diff(cputime),'ro-','linewidth',1)
xlabel('Time (sec.)')
ylabel('Frequency (Hz)')
set(gca,'FontSize',16)


figure(3);
% delu_postProcess = kp*h_error + kd*del_e_h+ki*e_int;
% delu_postProcess = max(-u_max,min(u_max,delu_postProcess));
% plot(cputime,delu_postProcess*129,'bo-','linewidth',2)
plot(cputime,u_actual*129,'ro-','linewidth',1);
xlabel('Time (sec.)')
ylabel('Control Input')
set(gca,'FontSize',16)
%hold on;
% legend('delu postprocess','u actual');

figure(4);
plot(cputime(1:end),v_z_sp,'ro-','linewidth',1)
xlabel('Time (sec.)')
ylabel('velocity sp')
set(gca,'FontSize',16)

% figure(4);
% plot(u_stick_net(:,1).*129,'ro-','linewidth',2)
% xlabel('Time (sec.)')
% ylabel('u stick net(1)')
% set(gca,'FontSize',16)
