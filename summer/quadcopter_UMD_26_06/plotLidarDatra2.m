%  clear all; close all; clc;
kp = 0.2;
kd = 0.06;
ki = 0.025;
h_des = 0.8;
u_max = 0.25;
data = csvread('lidar_data_z1.csv');
cputime = data(:,1) - data(1,1);
cputime2 = etime(data(:,7),data(1,7));
z_cur = data(:,2);
z_cur_unfiltered = data(:,3);
h_error = data(:,4);
del_e_h = data(:,5);
u_actual = data(:,6);
e_int =zeros(length(h_error),1);
for i = 2:length(h_error)
    e_int(i) = e_int(i-1) + h_error(i);
end
figure(1);
subplot(3,1,1)
plot(cputime2, z_cur, 'ro-','linewidth',2);
hold on
plot(cputime2, z_cur_unfiltered,'bo-','linewidth',2);
plot(cputime2, ones(size(cputime))*h_des,'k--')
xlabel('Time (sec.)')
ylabel('Altitude (m)')
legend('Filtered Lidar','Raw Lidar')
set(gca,'FontSize',16)

subplot(3,1,2)
plot(cputime, del_e_h,'bo-','linewidth',2);
xlabel('Time (sec.)')
ylabel('Altitude-Rate ')
set(gca,'FontSize',16)

subplot(3,1,3)
plot(cputime, h_error,'bo-','linewidth',2);
xlabel('Time (sec.)')
ylabel('Altitude Error (m)')
set(gca,'FontSize',16)

figure(2);
plot(cputime(1:end-1),1./diff(cputime),'ro-','linewidth',2)
xlabel('Time (sec.)')
ylabel('Frequency (Hz)')
set(gca,'FontSize',16)


figure(3);
delu_postProcess = kp*h_error + kd*del_e_h+ki*e_int;
delu_postProcess = max(-u_max,min(u_max,delu_postProcess));
plot(cputime,delu_postProcess*129,'bo-','linewidth',2)
xlabel('Time (sec.)')
ylabel('Control Input')
set(gca,'FontSize',16)
hold on;
plot(cputime,u_actual*129,'ro-','linewidth',2);
legend('delu_postprocess','u_actual');
