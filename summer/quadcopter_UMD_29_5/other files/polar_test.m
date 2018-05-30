%   f = figure;
% ax = axes('Parent',f,'position',[0.13 0.39  0.77 0.54]);
% % pax = polaraxes('parent',f);
% cp = ginput()
function polar_test()
theta = 0:0.01:2*pi;
rho = sin(2*theta).*cos(2*theta);
% figure;
ax(1) = polar(theta,rho,'--r');
hold on
ax(2) = polar(0,0,'g*');
set (gcf, 'WindowButtonMotionFcn', {@mouseMove,ax});
function mouseMove(object, eventdata,ax)
    C = get (gca, 'CurrentPoint')
% [theta rho] = cart2pol(C(1,1), C(1,2));
% title(gca, ['(angle,factor) = (', num2str(theta*180/pi), ', ',num2str(rho), ')']);
% markerspot = sin(2*theta).*cos(2*theta);
% [x y]=pol2cart(theta,markerspot);
% set(ax(2),'xData',x,'yData',y,'markersize',20);
set(ax(2),'xData',C(1,1),'yData',C(1,2),'markersize',20);

drawnow
end
end