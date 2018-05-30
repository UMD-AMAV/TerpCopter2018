function test(h)
% close all
% clearvars
% h =figure('WindowButtonDownFcn',@wbdcb,'units','normalized');
% h = figure('units','normalized');
pax(1) = polaraxes('parent',h,'RLim', [0 1],'units','normalized');
pax(1).RLimMode = 'manual';
disp(pax(1).Position);
%  pax(1).RTickLabel = {};
hold on
pax(2) = polarplot(pax(1),0,0,'Marker','o','MarkerSize', 16, 'MarkerFaceColor','r','MarkerEdgeColor','k');
set (gcf, 'WindowButtonDownFcn', {@wbdcb,pax});

% polarplot(pax,deg2rad(0),0,'Marker','o','MarkerSize', 16, 'MarkerFaceColor','r','MarkerEdgeColor','k');
% cla
% polarplot(pax,deg2rad(0),.8,'Marker','o','MarkerSize', 16, 'MarkerFaceColor','r','MarkerEdgeColor','k');

% figure('WindowButtonDownFcn',@wbdcb)
% ah = axes('DrawMode','fast');
% axis ([1 10 1 10])
   
   function wbdcb(src,evnt,pax)
      if strcmp(get(src,'SelectionType'),'normal')
         cp1 = get(src,'CurrentPoint')% get mouse click position
          if ( (cp1(1,1)>=0.45 && cp1(1,1)<=0.55)&&(cp1(1,2)>=0.45 && cp1(1,2)<=0.55) )
                % if mouse pointer is clicked at the origin
                % drawnow % updates graphics and processes pending callbacks
                set(src,'WindowButtonMotionFcn',{@wbmcb,pax})
                drawnow
          end
      elseif strcmp(get(src,'SelectionType'),'alt')
                 %bring stick back to origin in finite time
                % send stick commands
                set(pax(2),'ThetaData',0,'RData',0,'MarkerSize',16,'MarkerFaceColor','r');
                set(src,'WindowButtonMotionFcn','')
                drawnow      
      end
   
      
      function wbmcb(src,evnt,pax)
         % calculate and send stick commands 
         % update stick position
          cp = get(src,'CurrentPoint')
          [theta rho] = cart2pol(cp(1,1)-0.5, cp(1,2)-0.5);
          set(pax(2),'ThetaData',theta,'RData',rho,'Marker','o','MarkerSize',...
                   16, 'MarkerFaceColor','r','MarkerEdgeColor','k');
               drawnow
%          polarplot(pax(2),cp,'Marker','o','MarkerSize',...
%                    16, 'MarkerFaceColor','r','MarkerEdgeColor','k');
%          [xn,yn,str] = disp_point(ah);
%          xdat = [x,xn];
%          ydat = [y,yn];
%          set(hl,'XData',xdat,'YData',ydat);
      end  
   end
   
%    function [x,y,str] = disp_point(ah)
%       cp = get(ah,'CurrentPoint');  
%       x = cp(1,1);y = cp(1,2);
%       str = ['(',num2str(x,'%0.3g'),', ',num2str(y,'%0.3g'),')'];    
%    end
%  

end