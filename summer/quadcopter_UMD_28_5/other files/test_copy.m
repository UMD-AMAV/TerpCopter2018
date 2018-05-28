function l_joy(h,sTrainerBox,pax) % h = handle to axes
disp('entering test copy');
delete(findall(gca,'type','text'));
set (gcf, 'KeyPressFcn', {@kpcb,pax,sTrainerBox},'units','normalized');
    function kpcb(src,evnt,pax,sTrainerBox)
      
        keypressed = evnt.Key;
       switch( keypressed)
           case {'W','w'}
               % update marker pos
               cp1 =[pax.XData, (pax.YData+0.05) ];
               wbmcb(pax,cp1,sTrainerBox);
                 
           case {'S','s'}
               % update marker pos
               cp1 =[pax.XData, (pax.YData-0.05) ];
               wbmcb(pax,cp1,sTrainerBox);
               
           case {'D','d'}
               % update marker pos
               cp1 =[(pax.XData+0.05), pax.YData ];
               wbmcb(pax,cp1,sTrainerBox);
               
           case {'A','a'}
               % update marker pos
               cp1 =[(pax.XData-0.05), pax.YData ];
               wbmcb(pax,cp1,sTrainerBox);
          
           case {'Z','z'}
               % update marker pos
               cp1 =[0, pax.YData ];
               wbmcb(pax,cp1,sTrainerBox);
               
       end
      
      function wbmcb(pax,cp1,sTrainerBox)
          cp1(1,1)= max(-1,min(1,cp1(1,1)));
          cp1(1,2)= max(-1,min(1,cp1(1,2)));
          set(pax,'xData',cp1(1,1),'yData',cp1(1,2),'MarkerSize',16,'MarkerFaceColor','r');
          drawnow
          % get stick commands based on marker position
          % note: u_stick_cmd lies between [-1 1]
          u_stick_cmd(1) = cp1(1,2); 
          u_stick_cmd(2) = inf;
          u_stick_cmd(3) = inf;
          u_stick_cmd(4) = cp1(1,1);
          
          % set trim values to inf here, trim will be set by slider
          % callback
          trim_scaled(1:4) = inf;
          send_stick_cmd(u_stick_cmd,trim_scaled,sTrainerBox,pax);
%          
%             channel1Command = 5000+ 4000*u_stick(1);  % throttle (up)
%             channel2Command = 5000- 4000*u_stick(2);  % roll     (right)
%             channel3Command = 5000+ 4000*u_stick(3);  % pitch    (forward)
%             channel4Command = 5000- 4000*u_stick(4);  % yaw
%             % change sign to reverse
%     
%             fprintf(sTrainerBox,'a');
%             fprintf(sTrainerBox,int2str(channel1Command));
%             fprintf(sTrainerBox,int2str(channel2Command));
%             fprintf(sTrainerBox,int2str(channel3Command));
%             fprintf(sTrainerBox,int2str(channel4Command));
%             fprintf(sTrainerBox,'z');
%             disp('channel_cmnd');
%             disp([channel1Command,channel2Command,channel3Command,channel4Command]')

     end  
   end
   
disp('exiting test copy');

end