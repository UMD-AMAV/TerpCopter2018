close all
clear all
% Physical properties
params.gravity = 9.81;
params.mass = 0.522;
K = 4.555764;
tl = 29;
sl = 100;
ut0 = 0/29; % trim tab value; fixed
umax = 0.4;
s_des = [1; 0];

kv =5;
kp = 1;
ki = 0.1;

e_prev = 0;
e_sum = 0;
dt = 0.01;

tspan = 0:dt:10;
y = zeros(length(tspan),2);
s = [0.2;0];
y(1,: ) = s;
u_stick = 0;
u(1) = 0;
for i = 1:length(tspan)-1
    e = s_des(1) - s(1);
    if (~mod(i,20)|| i==1)
        del_e = e-e_prev;
        delu = kp*e+kv*del_e+ki*e_sum;
        u_stick = 0 + delu;
        u_stick = min(max(-umax, u_stick),umax);
        e_sum = e_sum+ e;
        e_prev = e;

    end
    u(i+1) = u_stick;
    u_net = (u(i)*sl + ut0*tl)/(sl+tl);
    u_net = min(max(-1, u_net),1);
    T = K*(u_net +1);
    
    sdot(:,i) = [s(2);T/params.mass - params.gravity];
    y(i+1,:) = y(i,:) + (sdot(:,i)*dt)';
        s = y(i+1,:)';
end
sdot = sdot';
figure;
plot(tspan,y(:,1));
xlabel('t');
ylabel('h');
grid on

figure(2);
plot(tspan(1:end),u*129);
xlabel('t');
ylabel('u');
grid on

figure(3);
plot(tspan(1:end-1),sdot);
xlabel('t');
ylabel('sdot');
legend('velocity','acceleration');
grid on
% observations
 % control works for frequency > 2Hz