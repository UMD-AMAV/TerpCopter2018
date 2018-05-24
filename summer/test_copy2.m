function test_copy2(h)
disp('entering test_copy2');

% set marker position
pax1 = polar(h,0,0,'bo');
set(pax1,'MarkerSize',16,'MarkerFaceColor','b');
ax = gca;
set (gcf, 'WindowButtonDownFcn', {@wbdcb,pax1,ax},'units','normalized');
% initialise stick values
cmd_pitch = pax1.YData 
cmd_roll = pax1.XData 

    
   function wbdcb(src,evnt,pax1,ax)
      if strcmp(get(src,'SelectionType'),'normal')
          cp1 = get(ax,'CurrentPoint')% get mouse click position
         % returns mouse click pos in cartesian coordinates
         % if ( (cp1(1,1)>=0.45 && cp1(1,1)<=0.55)&&(cp1(1,2)>=0.45 && cp1(1,2)<=0.55) )
           if  (cp1(1,1)>=-0.1 && cp1(1,1)<=0.1)
                % if mouse pointer is clicked at the origin
                %update graphics and process pending callbacks
                drawnow
                set(src,'WindowButtonMotionFcn',{@wbmcb,pax1,ax})
               
          end
      elseif strcmp(get(src,'SelectionType'),'alt')
                %bring stick back to origin in finite time
                % send stick commands
                set(pax1,'xData',0,'yData',0,'MarkerSize',16,'MarkerFaceColor','b');
                set(src,'WindowButtonMotionFcn','')
                drawnow
      end
   
      
      function wbmcb(src,evnt,pax1,ax)
         % calculate and send stick commands 
         % update stick position
          cp = get(ax,'CurrentPoint')
          cp(1,1)= max(-1,min(1,cp(1,1)));
          cp(1,2)= max(-1,min(1,cp(1,2)));
          set(pax1,'xData',cp(1,1),'yData',cp(1,2),'MarkerSize',16,'MarkerFaceColor','b');
          drawnow
          
          % get stick commands based on marker position
          % note: cmd_stick lies between [-1 1]
          cmd_pitch = cp(1,2); %thrust 
          cmd_roll = cp(1,1); %yaw rate
      end  
   end
   
disp('exiting test_copy2');
 end