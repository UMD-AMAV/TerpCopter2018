% 
% THIS FILE SUBSCRIBES GRAPHS THE TRAJECTORIES OF POSITION X,Y,Z

% AUTHOR: SAIMOULI KATRAGADDA, DEREK PALEY
% AFFILIATION : UNIVERSITY OF MARYLAND 
% EMAIL : SKATRAGA@TERPMAIL.UMD.EDU

% THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THE GPLv3 LICENSE
% THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. ANY USE OF
% THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
% PROHIBITED.
%  
% BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO
% BE BOUND BY THE TERMS OF THIS LICENSE. THE LICENSOR GRANTS YOU THE RIGHTS
% CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH TERMS AND
% CONDITIONS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% rosinit('10.1.10.204'); % only the first time

% set(gca,'xlim',[800 2000])
% set(gca,'xlim',[0 12294])

pose = rossubscriber('/mavros/local_position/pose');

posX = [];
posY = [];
posZ = [];

t=0;

figure(gcf), clf
subplot(3,1,1); set(gca,'ylim',[-5,5])
hold on, ylabel('x (m)')

subplot(3,1,2); set(gca,'ylim',[-5,5])
hold on, ylabel('y (m)')

subplot(3,1,3); set(gca,'ylim',[-1,5])
hold on, ylabel('z (m)')
i=1;
while (1)
    msgPose = receive(pose,10);
    
    posX(i) = msgPose.Pose.Position.X;
    posY(i) = msgPose.Pose.Position.Y;
    posZ(i) = msgPose.Pose.Position.Z;
    t= msgPose.Header.Seq; %t+1;
    i=i+1;
    
    figure(1);
    subplot(3,1,1);
    plot(t,posX,'r.'); set(gca,'xlim',[t-100 t])
    
    subplot(3,1,2);
    plot(t,posY,'b.'); set(gca,'xlim',[t-100 t])
    
    subplot(3,1,3);
    plot(t,posZ,'m.'); set(gca,'xlim',[t-100 t])
    
    figure(2);
    plot3(posX,posY,posZ,'.r');
    legend('x','y','z');grid on;
      
end

