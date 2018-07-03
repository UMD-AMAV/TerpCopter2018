close all
clear all
clc
% Physical properties
params.gravity = 9.81;
params.mass = 0.522;
K = 4.555764;
tl = 29;
sl = 100;
ut0 = 0/29; % trim tab value; fixed
umax = 1;
v_z_max = 5;
s_des = [1.5; 0];

kvh =0.01;
kph = 1;
kih = 4;
kh = 2;

v_z_error_int = 0;
z_prev = 0;
z_dot_prev = 0;
dt = 0.01;

tspan = 0:dt:10;
y = zeros(length(tspan),2);
s = [0.2;0];
y(1,: ) = s;
u_stick = 0;
u(1) = 0;

for i = 1:length(tspan)-1
    h_error = s_des(1) - s(1)
    z_cur = s(1);
    if (i==1)
       z_dot = 0;
       z_prev = z_cur;
       z_d_dot = 0;
       del_t = 0;
       t_prev = tspan(i);
       z_dot_prev = z_dot;
     
    elseif (~mod(i,10))
       v_z_sp = kh*h_error
       v_z_sp = max(-v_z_max,min(v_z_max,v_z_sp));
       del_t = tspan(i)-t_prev;
       z_dot  = (z_cur - z_prev)/del_t;
       t_prev = tspan(i);
       z_prev = z_cur;
       z_d_dot = (z_dot-z_dot_prev)/dt;
       z_dot_prev = z_dot;
       %velocity control loop
       v_z_error = v_z_sp - z_dot;
       v_z_error_dot = -kh*z_dot - z_d_dot;
       %calculate thrust
       u_stick= (0+(kph*v_z_error+kvh*v_z_error_dot+ v_z_error_int));
       u_stick = max(-umax, min(umax,u_stick));
  
       %anti-windup
       stop_v_z_error_int = (u_stick>=umax && v_z_error>=0 )||(u_stick<=-umax && v_z_error<=0);
       if ~stop_v_z_error_int, v_z_error_int = v_z_error_int + kih*v_z_error*dt; end
  
    end
    
    u(i+1) = u_stick;
    u_net = (u(i)*sl + ut0*tl)/(sl+tl);
    u_net = min(max(-1, u_net),1);
    T = K*(u_net +1);
    zdot(i) = z_dot;
    zddot(i) = z_d_dot;
    sdot(:,i) = [s(2);T/params.mass - params.gravity];
    y(i+1,:) = y(i,:) + (sdot(:,i)*dt)';
    s = y(i+1,:)';
end

sdot = sdot';

subplot(3,1,1);
plot(tspan,y(:,1));
xlabel('t');
ylabel('h');
hold on; plot(tspan,s_des(1)*ones(length(tspan)),'--r');
grid on
legend('current height','desired height');

subplot(3,1,2);
plot(tspan(1:end-1),zdot);
hold on; plot(tspan,y(:,2));
xlabel('t');
ylabel('vertical velocity');
grid on
legend('approx','actual');

subplot(3,1,3);
plot(tspan(1:end-1),sdot(:,2));
hold on; plot(tspan(1:end-1),zddot);
xlabel('t');
ylabel('vertical acceleration');
legend('actual','aprrox');
grid on

figure(2);
plot(tspan,u*129);
xlabel('time(s)');
ylabel('control input');
grid on;
