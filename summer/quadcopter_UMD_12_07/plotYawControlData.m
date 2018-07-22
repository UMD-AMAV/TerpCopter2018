clear all; close all; clc;
addpath('./results and plots');

data = csvread('yaw_control_data_test_12_07.csv');
cputime = data(:,1)-data(1,1);
des_yaw = rad2deg(data(:,2));
cur_yaw = rad2deg(data(:,3));
u_stick_yaw = data(:,4);

figure(1);
subplot(2,1,1)
plot(cputime, des_yaw, 'ko-');
hold on
plot(cputime, cur_yaw,'bo-');
xlabel('Time (sec.)')
ylabel('yaw angle(deg)')
legend('desired','actual')
set(gca,'FontSize',16);
grid on;

subplot(2,1,2)
plot(cputime, u_stick_yaw,'ro-');
xlabel('Time (sec.)')
ylabel('yaw stick input(norm.)')
set(gca,'FontSize',16);
grid on;

figure(2);
plot(cputime(1:end-1),1./diff(cputime),'ro-')
xlabel('Time (sec.)')
ylabel('Frequency (Hz)')
set(gca,'FontSize',16)
grid on;