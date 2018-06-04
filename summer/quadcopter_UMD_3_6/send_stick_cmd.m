function [stickValues,textDispVecUpdated] = send_stick_cmd(u_stick_cmd,trim_scaled,...
                       sTrainerBox,stick_lim,pax,textDispVec)
%  disp('executing send_stick_cmd');
 
 persistent u_stick trim call_no;
 u_stick_net = zeros(4,1);
 if(isempty(call_no))
    call_no = 1;
 else
    call_no = call_no+1;
 end
%  call_no

for i = 1:4
    if (u_stick_cmd(i) ~=inf)
        u_stick(i,1) = u_stick_cmd(i);
    end
end
% u_stick
% update stick positions
set(pax(1),'xData',u_stick(4),'yData',u_stick(1),'MarkerSize',16,'MarkerFaceColor','r');
set(pax(2),'xData',u_stick(2),'yData',u_stick(3),'MarkerSize',16,'MarkerFaceColor','b');
drawnow          
% disp('pax1.ydata:');
% disp(pax(1).YData);
% disp('pax2.ydata:');
% disp(pax(2).YData);


for i = 1:4    
    if (trim_scaled(i) ~=inf)
        trim(i,1) = trim_scaled(i);
    end 
    u_stick_net(i) = u_stick(i) + trim(i);
    u_stick_net(i)= max(-1,min(1,u_stick_net(i)));
end

% disp('trim');
% disp(trim);

            channel1Command = 5000+ 4000*u_stick_net(1);  % throttle (up)
            channel2Command = 5000- 4000*u_stick_net(2);  % roll     (right)
            channel3Command = 5000+ 4000*u_stick_net(3);  % pitch    (forward)
            channel4Command = 5000- 4000*u_stick_net(4);  % yaw
            % change sign to reverse
    
            fprintf(sTrainerBox,'a');
            fprintf(sTrainerBox,int2str(channel1Command));
            fprintf(sTrainerBox,int2str(channel2Command));
            fprintf(sTrainerBox,int2str(channel3Command));
            fprintf(sTrainerBox,int2str(channel4Command));
            fprintf(sTrainerBox,'z');
%             disp('channel_cmnd');
%             disp([channel1Command,channel2Command,channel3Command,channel4Command]);
% class(stick_lim)
% class(u_stick)
% calculate stick values
stickValues = u_stick_net.*stick_lim;
% disp('stickvalues');
% disp(stickValues);
%update text display
for i = 1:4
set(textDispVec(i),'String',num2str(stickValues(i)));
end

textDispVecUpdated = textDispVec;
end  

          
