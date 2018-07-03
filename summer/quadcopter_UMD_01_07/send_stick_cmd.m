function  send_stick_cmd(u_stick_cmd,trim,handles)
tic
disp('executing send_stick_cmd');
persistent u_stick trim1;

indx = find(u_stick_cmd~=inf);
u_stick(indx,1) = u_stick_cmd(indx);
     
indx = find(trim~=inf);
trim1(indx,1) = trim(indx);
temp = (handles.stick_lim + handles.trim_lim);
u_stick_net = u_stick.*handles.stick_lim+ trim1.*handles.trim_lim;
u_stick_net = u_stick_net./temp;
u_stick_net= max(-1,min(1,u_stick_net));

%u_stick_net(1)
%for debugging
%K = 4.555764;
%T = K*(u_stick_net +1);
%disp('trim');
%disp(trim1);

channel1Command = 5000+ 4000*u_stick_net(1);  % throttle (up)
channel2Command = 5000- 4000*u_stick_net(2);  % roll     (right)
channel3Command = 5000+ 4000*u_stick_net(3);  % pitch    (forward)
channel4Command = 5000- 4000*u_stick_net(4);  % yaw
%change sign to reverse
   
fprintf(handles.sTrainerBox,'a');
fprintf(handles.sTrainerBox,int2str(channel1Command));
fprintf(handles.sTrainerBox,int2str(channel2Command));
fprintf(handles.sTrainerBox,int2str(channel3Command));
fprintf(handles.sTrainerBox,int2str(channel4Command));
fprintf(handles.sTrainerBox,'z');
          

%the above fprintf statements take 0.03 sec to execute
%the rest of the code takes 0.005 sec to execute

% slective update of gui to speed up function call,
if handles.yaw_control_radio.Value == 1
    %update stick position
    set(handles.pax(1),'xData',u_stick(4));
    drawnow limitrate;
elseif handles.altitude_control_radio.Value == 1
    set(handles.pax(1),'yData',u_stick(1));
    drawnow limitrate;          

else
    set(handles.pax(1),'xData',u_stick(4),'yData',u_stick(1));
    set(handles.pax(2),'xData',u_stick(2),'yData',u_stick(3));
              

    stickValues = u_stick_net.*(handles.stick_lim+handles.trim_lim);
    stickValues(1:4) = round(stickValues(1:4),0);
   
    set(handles.thrustDisplay,'String',num2str(stickValues(1)));
    set(handles.rollDisplay,'String',num2str(stickValues(2)));
    set(handles.pitchDisplay,'String',num2str(stickValues(3)));
    set(handles.yawDisplay,'String',num2str(stickValues(4)));
    drawnow limitrate;
end 
toc
end

          
