function test_copy(h) % h = hnadle to axes
disp('entering test copy');

% set marker position on gui
pax = polar(h,deg2rad(270),1,'ro');
set(pax,'MarkerSize',16,'MarkerFaceColor','r');
set (gcf, 'KeyPressFcn', {@kpcb,pax},'units','normalized');
% initialise stick values
u_stick_cmd(1) = pax.YData; 
u_stick_cmd(2) = inf;
u_stick_cmd(3) = inf;
u_stick_cmd(4) = pax.XData;
send_stick_cmd(u_stick_cmd);

    function kpcb(src,evnt,pax)
      
       keypressed = evnt.Key;
       switch( keypressed)
           case {'W','w'}
               % update marker pos
               cp1 =[pax.XData, (pax.YData+0.05) ];
               wbmcb(pax,cp1);
                 
           
           case {'S','s'}
               % update marker pos
               cp1 =[pax.XData, (pax.YData-0.05) ];
               wbmcb(pax,cp1);
               
           case {'D','d'}
               % update marker pos
               cp1 =[(pax.XData+0.05), pax.YData ];
               wbmcb(pax,cp1);
               
           case {'A','a'}
               % update marker pos
               cp1 =[(pax.XData-0.05), pax.YData ];
               wbmcb(pax,cp1);
          
           case {'Z','z'}
               % update marker pos
               cp1 =[0, pax.YData ];
               wbmcb(pax,cp1);
               
               
       end
      
      function wbmcb(pax,cp1)
         % update stick position
          %cp1
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
          send_stick_cmd(u_stick_cmd);
     end  
   end
   
disp('exiting test copy');

end