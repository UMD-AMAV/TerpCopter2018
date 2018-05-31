function buttonDownFcn_example()
close all
%     
%     function lineCallback(src,~)
%             src.Color = rand(1,3);
%             src.radius
%     end
% 
%     plot(rand(1,5),'ButtonDownFcn',@lineCallback)
%     hold on
%     plot((1:10),'ButtonDownFcn',@lineCallback)
%     
%     viscircles([5,5],1);
%     
%     
 
% Click the left mouse button to define a point
% Drag the mouse to draw a line to the next point and
% left click again
% Right click the mouse to stop drawing
% 

% figure('WindowButtonDownFcn',@wbdcb)
ah = axes('DrawMode','fast');
axis ([1 12 1 10])
   function wbdcb(src,evnt)
      if strcmp(get(src,'SelectionType'),'normal')       
         [x,y,str] = disp_point(ah);
         hl = line('XData',x,'YData',y,'Marker','.');
         text(x,y,str,'VerticalAlignment','bottom');drawnow
         set(src,'WindowButtonMotionFcn',@wbmcb)
      elseif strcmp(get(src,'SelectionType'),'alt')
         set(src,'WindowButtonMotionFcn','')
         [x,y,str] = disp_point(ah);
         text(x,y,str,'VerticalAlignment','bottom');drawnow
      end
      function wbmcb(src,evnt)
         [xn,yn,str] = disp_point(ah);
         xdat = [x,xn];
         ydat = [y,yn];
         set(hl,'XData',xdat,'YData',ydat);
      end  
   end
   function [x,y,str] = disp_point(ah)
      cp = get(ah,'CurrentPoint');  
      x = cp(1,1);y = cp(1,2);
      str = ['(',num2str(x,'%0.3g'),', ',num2str(y,'%0.3g'),')'];    
   end
 

end