function test_copy2copy(h,sTrainerBox,stick_lim,pax,textDispVec)
% disp('entering test_copy2');
% 
% % set marker position
% pax1 = polar(h,0,0,'bo');
% set(pax1,'MarkerSize',16,'MarkerFaceColor','b');
%  delete(findall(h,'type','text'));
% ax = h;
set (gcf, 'WindowButtonDownFcn', {@wbdcb,pax,ax,sTrainerBox},'units','normalized');

      function wbdcb(src,evnt,pax,ax,sTrainerBox)
      if strcmp(get(src,'SelectionType'),'normal')
          cp1 = get(ax,'CurrentPoint')
         % returns mouse click pos in cartesian coordinates
           if  (cp1(1,1)>=-0.1 && cp1(1,1)<=0.1)
                % if mouse pointer is clicked at the origin
                %update graphics and process pending callbacks
                drawnow
                set(src,'WindowButtonMotionFcn',{@wbmcb,pax,ax,sTrainerBox})
               
          end
      elseif strcmp(get(src,'SelectionType'),'alt')
                %bring stick back to origin in finite time
                % send stick commands
                set(pax1,'xData',0,'yData',0,'MarkerSize',16,'MarkerFaceColor','b');
                set(src,'WindowButtonMotionFcn','')
                drawnow
                u_stick_cmd(1) = inf; 
                u_stick_cmd(2) = 0;
                u_stick_cmd(3) = 0;
                u_stick_cmd(4) = inf;
                
                % set trim values to inf here, trim will be set by slider
                % callback
                trim_scaled(1:4) = inf;
                send_stick_cmd(u_stick_cmd,trim_scaled,...
               sTrainerBox,stick_lim,pax,textDispVec);
      end
   
      
      function wbmcb(src,evnt,pax,ax,sTrainerBox)
         % calculate and send stick commands 
         % update stick position
          cp = get(ax,'CurrentPoint')
          cp(1,1)= max(-1,min(1,cp(1,1)));
          cp(1,2)= max(-1,min(1,cp(1,2)));
          set(pax,'xData',cp(1,1),'yData',cp(1,2),'MarkerSize',16,'MarkerFaceColor','b');
          drawnow
          
          u_stick_cmd(1) = inf; 
          u_stick_cmd(2) = cp(1,1);
          u_stick_cmd(3) = cp(1,2);
          u_stick_cmd(4) = inf;
          trim_scaled(1:4) = inf;
          send_stick_cmd(u_stick_cmd,trim_scaled,...
               sTrainerBox,stick_lim,pax,textDispVec);
  
      end  
     end
   
disp('exiting test_copy2');
 end