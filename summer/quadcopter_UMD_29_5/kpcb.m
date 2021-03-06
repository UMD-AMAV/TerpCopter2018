function kpcb(src,evnt,sTrainerBox,stick_lim,pax,textDispVec)
   disp('key pressed');   
        keypressed = evnt.Key;
       switch( keypressed)
           case {'W','w'}
               % update marker pos
               cp1 =[pax(1).XData, (pax(1).YData+(4/147)) ];
               cp2 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
               
           case {'S','s'}
               % update marker pos
               cp1 =[pax(1).XData, (pax(1).YData-(4/147)) ];
               cp2 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
               
           case {'D','d'}
               % update marker pos
               % if stick is on left, bring to center
               if pax(1).XData<0
                  cp1 = [0, pax(1).YData];
               else
                  cp1 =[(pax(1).XData+(1/147)), pax(1).YData ];
               end
               cp2 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
               
           case {'A','a'}
               % update marker pos
               % if stick is on left, bring to center
               if pax(1).XData>0
                  cp1 = [0, pax(1).YData];
               else
                  cp1 =[(pax(1).XData-(1/147)), pax(1).YData ];
               end
               cp2 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
               
           case {'Z','z'}
               % update marker pos
               cp1 =[0, pax(1).YData ];
               cp2 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
               
           case {'uparrow'}
               % update marker pos
               % if stick is on left, bring to center
               if pax(2).YData<0
                  cp2 = [pax(2).XData,0];
               else
                  cp2 =[pax(2).XData,(pax(2).YData+((3/147))) ];
               end
               cp1 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
           
           case {'downarrow'}
               % update marker pos
               if pax(2).YData>0
                  cp2 = [pax(2).XData,0];
               else
                  cp2 =[pax(2).XData,(pax(2).YData-(3/147)) ];
               end
               cp1 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
               
           case {'rightarrow'}
               % update marker pos
               if pax(2).XData<0
                  cp2 = [0,pax(2).YData];
               else
                  cp2 =[(pax(2).XData+(3/147)),pax(2).YData ];
               end
               cp1 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
               
           case {'leftarrow'}
               % update marker pos
               if pax(2).XData>0
                  cp2 = [0,pax(2).YData];
               else
               cp2 =[(pax(2).XData-((3/147))),pax(2).YData ];
               end
               cp1 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
          
           case {'shift'}
               % update marker pos
               cp2 =[0, 0 ];
               cp1 = [inf,inf];
               wbmcb(pax,cp1,cp2,sTrainerBox);
       end
               
           
      function wbmcb(pax,cp1,cp2,sTrainerBox)
          if cp1(1,1)~=inf, cp1(1,1)= max(-1,min(1,cp1(1,1)));end
          if cp1(1,2)~=inf, cp1(1,2)= max(-1,min(1,cp1(1,2)));end
          cp1
          cp2
          if cp2(1,1)~=inf, cp2(1,1)= max(-1,min(1,cp2(1,1)));end
          if cp2(1,2)~=inf, cp2(1,2)= max(-1,min(1,cp2(1,2)));end
          % get stick commands based on marker position
          % note: u_stick_cmd lies between [-1 1]
          u_stick_cmd(1) = cp1(1,2); 
          u_stick_cmd(2) = cp2(1,1);
          u_stick_cmd(3) = cp2(1,2);
          u_stick_cmd(4) = cp1(1,1);
          
          % set trim values to inf here, trim will be set by slider
          % callback
          trim_scaled(1:4) = inf;
          disp('calling send_stick_cmd()');
          send_stick_cmd(u_stick_cmd,trim_scaled,...
              sTrainerBox,stick_lim,pax,textDispVec);

     end  
end