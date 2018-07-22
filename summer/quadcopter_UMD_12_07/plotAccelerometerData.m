clear all; close all; clc;

data = csvread('accelerometer_data.csv');
acc_imu_x = data(:,1);
acc_imu_y = data(:,2);
acc_imu_z = data(:,3);
u_dot_forward = data(:,4);
u_dot_crab = data(:,5);
u_forward = data(:,6);
u_crab = data(:,7);


figure(1);
subplot(3,1,1)
plot(acc_imu_x, 'ro-');
xlabel('iteration');
ylabel('imu acc x');

subplot(3,1,2)
plot(acc_imu_y, 'ro-');
xlabel('iteration');
ylabel('imu acc y');

subplot(3,1,3)
plot(acc_imu_z, 'ro-');
xlabel('iteration');
ylabel('imu acc z');

figure(2);
subplot(2,1,1)
plot(u_dot_forward,'ro-');
xlabel('iteration')
ylabel('u dot forward')

subplot(2,1,2)
plot(u_dot_crab,'ro-');
xlabel('iteration')
ylabel('u dot crab')

figure(3);
subplot(2,1,1)
plot(u_forward,'ro-');
xlabel('iteration')
ylabel('u  forward')

subplot(2,1,2)
plot(u_crab,'ro-');
xlabel('iteration')
ylabel('u crab')

