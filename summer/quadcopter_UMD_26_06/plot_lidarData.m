load('lidar_data.m');
z_current = lidar_data(:,1);
z_dot = lidar_data(:,3)./0.01;

figure(1);
plot(z_current);

figure(2);
plot(z_dot);