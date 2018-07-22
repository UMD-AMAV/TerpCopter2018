clear all; close all; clc;
addpath('./results and plots');
data = csvread('accelerometer_data2_forward_test_08_07.csv');
v_enu_x = data(:,1);
v_enu_y = data(:,2);
v_enu_z = data(:,3);
v_stability_x = data(:,4);
v_stability_y = data(:,5);
v_stability_z = data(:,6);
u_forward = data(:,7);
u_crab = data(:,8);
% psi = rad2deg(data(:,9));
% theta = rad2deg(data(:,10));
% phi = rad2deg(data(:,11));
% u_dot_forward = data(:,12);
% u_dot_crab = data(:,13);
% Z_d_dot = data(:,14);
% imu_acc_x = data(:,15);
% imu_acc_y = data(:,16);
% imu_acc_z = data(:,17);


figure(1);
subplot(3,1,1)
plot(v_enu_x, 'ro-');
xlabel('iteration');
ylabel('mavros vel x');
grid on;

subplot(3,1,2)
plot(v_enu_y, 'ro-');
xlabel('iteration');
ylabel('mavros vel y');
grid on;
subplot(3,1,3)
plot(v_enu_z, 'ro-');
xlabel('iteration');
ylabel('mavros vel z');
grid on;

figure(2);
grid on;
subplot(3,1,1)
plot(v_stability_x,'ro-');
xlabel('iteration')
ylabel('vx stability ')
grid on;

subplot(3,1,2)
plot(v_stability_y,'ro-');
xlabel('iteration')
ylabel('vy stability')
grid on;

subplot(3,1,3)
plot(v_stability_z,'ro-');
xlabel('iteration')
ylabel('vz stability')
grid on;
% 
% figure(3);
% grid on;
% subplot(2,1,1)
% plot(u_forward,'ro-');
% xlabel('iteration')
% ylabel('u  forward')
% grid on;
% 
% subplot(2,1,2)
% plot(u_crab,'ro-');
% xlabel('iteration')
% ylabel('u crab')
% grid on;
% 
% figure(4);
% subplot(3,1,1)
% plot(psi, 'ro-');
% xlabel('iteration');
% ylabel('imu yaw');
% grid on;
% 
% subplot(3,1,2)
% plot(theta, 'ro-');
% xlabel('iteration');
% ylabel('imu pitch');
% grid on;
% 
% subplot(3,1,3)
% plot(phi, 'ro-');
% xlabel('iteration');
% ylabel('imu roll');
% grid on;
% 
% % 
% figure(5);
% subplot(3,1,1)
% plot(imu_acc_x, 'ro-');
% xlabel('iteration');
% ylabel('imu acc x');
% grid on;
% 
% subplot(3,1,2)
% plot(imu_acc_y, 'ro-');
% xlabel('iteration');
% ylabel('imu acc y');
% grid on;
% 
% subplot(3,1,3)
% plot(imu_acc_z, 'ro-');
% xlabel('iteration');
% ylabel('imu acc z');
% grid on;
% 
% figure(6);
% subplot(3,1,1)
% plot(u_dot_forward, 'ro-');
% xlabel('iteration');
% ylabel('forward acc');
% grid on;
% 
% subplot(3,1,2)
% plot(u_dot_crab, 'ro-');
% xlabel('iteration');
% ylabel('crab acc');
% grid on;
% 
% subplot(3,1,3)
% plot(Z_d_dot, 'ro-');
% xlabel('iteration');
% ylabel('vertical acc');
% grid on;
% 
