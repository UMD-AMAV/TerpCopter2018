clear all; close all; clc;
data = csvread('speed_control_data.csv');
cputime = data(:,1)-data(1,1);
u_forward_des = data(:,2);
u_crab_des = data(:,3);
u_forward = data(:,4);
u_crab = data(:,5);
u_stick_cmd_roll = data(:,6);
u_stick_cmd_pitch = data(:,7);

figure(1);
subplot(2,1,1)
plot(cputime, u_forward_des, 'ro-');
hold on
plot(cputime, u_forward,'bo-');
xlabel('Time (sec.)')
ylabel('forward speed')
legend('desired','actual')
set(gca,'FontSize',16);

subplot(2,1,2)
plot(cputime, u_crab_des,'ro-','linewidth',1);
hold on
plot(cputime, u_crab,'bo-');
xlabel('Time (sec.)')
ylabel('crab speed')
legend('desired','actual')
set(gca,'FontSize',16);


figure(2);
plot(cputime(1:end-1),1./diff(cputime),'ro-','linewidth',1)
xlabel('Time (sec.)')
ylabel('Frequency (Hz)')
set(gca,'FontSize',16)


figure(3);
subplot(2,1,1)
plot(cputime, u_stick_cmd_roll,'ro-','linewidth',1);
xlabel('Time (sec.)')
ylabel('roll input')
set(gca,'FontSize',16);

subplot(2,1,2)
plot(cputime, u_stick_cmd_pitch,'ro-','linewidth',1);
xlabel('Time (sec.)')
ylabel('pitch input')
set(gca,'FontSize',16);
