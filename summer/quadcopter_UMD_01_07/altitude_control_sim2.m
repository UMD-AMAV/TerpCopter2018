close all
clear all
% Physical properties
params.gravity = 9.81;
params.mass = 0.522;
K = 4.555764;
tl = 29;
sl = 100;
ut0 = 0/29; % trim tab value; fixed

s_des = [0.5; 0];
kv =1000;
kp = 5;
ki = 0;

e_prev = 0;
e_sum = 0;
dt = 0.01;
tspan = 0:dt:10;
y = zeros(length(tspan),2);
s = [.2;0];
y(1,: ) = s;
e = zeros(length(tspan),1);
u = zeros(length(tspan),1);
sdot = zeros(2,length(tspan));
sdot(2,1:3) = params.gravity;

for i = 3:length(tspan)
    e(i) =s_des(1,1) - s(1,1);
    u(i) = u(i-1) + kp*e(i)+kv*e(i-1) + ki*e(i-2);
    u(i) = min(max(-1, u(i)),1);
    u_net = (u(i)*sl + ut0*tl)/(sl+tl);
    u_net = min(max(-1, u_net),1);
    T = K*(u_net +1);
    sdot(:,i) = [s(2);T/params.mass - params.gravity];
    y(i+1,:) = y(i,:) + (sdot(:,i)*dt)';
    s = y(i+1,:)';
end
sdot = sdot';
figure;
plot(tspan,y(1:end-1,1));
xlabel('t');
ylabel('h');
grid on

figure(2);
plot(tspan,u);
xlabel('t');
ylabel('u');
grid on

figure(3);
plot(tspan,sdot);
xlabel('t');
ylabel('sdot');
legend('velocity','acceleration');
grid on
