function wbmcb(src,evnt,handles,textDispVec,ax)
          scale_down_factor = .2;
          %  to reduce mouse sensitivity
          cp = (get(ax,'CurrentPoint'))*scale_down_factor;
          cp(1,1)= max(-1,min(1,cp(1,1)));
          cp(1,2)= max(-1,min(1,cp(1,2)));
          
          u_stick_cmd(1) = inf; 
          u_stick_cmd(2) = cp(1,1);
          u_stick_cmd(3) = cp(1,2);
          u_stick_cmd(4) = inf;
          
          trim_scaled(1:4) = inf;
          disp('calling send_stick_cmd()');
          send_stick_cmd(u_stick_cmd,trim_scaled,handles.sTrainerBox,...
          handles.stick_lim,handles.pax,textDispVec);
end  
