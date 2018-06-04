function wbucb(src,evnt,handles,textDispVec)
set(src,'WindowButtonMotionFcn','');
u_stick_cmd(1) = inf; 
u_stick_cmd(2) = 0;
u_stick_cmd(3) = 0;
u_stick_cmd(4) = inf;
          
trim_scaled(1:4) = inf;
disp('calling send_stick_cmd()');
send_stick_cmd(u_stick_cmd,trim_scaled,handles.sTrainerBox,...
handles.stick_lim,handles.pax,textDispVec);

end