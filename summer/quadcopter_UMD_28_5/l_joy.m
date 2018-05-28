function l_joy(h,sTrainerBox,stick_lim,pax,textDispVec) % h = handle to axes
disp('entering l joy');
delete(findall(h,'type','text'));
% disp(gcf);
set (gcf, 'KeyPressFcn', {@kpcb,sTrainerBox,stick_lim,pax,textDispVec},'units','normalized');
%     function kpcb(src,evnt,pax,sTrainerBox)
%       
%         keypressed = evnt.Key;
%        switch( keypressed)
%            case {'W','w'}
%                % update marker pos
%                cp1 =[pax(1).XData, (pax(1).YData+0.05) ];
%                wbmcb(pax,cp1,sTrainerBox);
%                  
%            case {'S','s'}
%                % update marker pos
%                cp1 =[pax(1).XData, (pax(1).YData-0.05) ];
%                wbmcb(pax,cp1,sTrainerBox);
%                
%            case {'D','d'}
%                % update marker pos
%                cp1 =[(pax(1).XData+0.05), pax(1).YData ];
%                wbmcb(pax,cp1,sTrainerBox);
%                
%            case {'A','a'}
%                % update marker pos
%                cp1 =[(pax(1).XData-0.05), pax(1).YData ];
%                wbmcb(pax,cp1,sTrainerBox);
%           
%            case {'Z','z'}
%                % update marker pos
%                cp1 =[0, pax(1).YData ];
%                wbmcb(pax,cp1,sTrainerBox);
%                
%        end
%       
%       function wbmcb(pax,cp1,sTrainerBox)
%           cp1(1,1)= max(-1,min(1,cp1(1,1)));
%           cp1(1,2)= max(-1,min(1,cp1(1,2)));
%           cp1
%           % get stick commands based on marker position
%           % note: u_stick_cmd lies between [-1 1]
%           u_stick_cmd(1) = cp1(1,2); 
%           u_stick_cmd(2) = inf;
%           u_stick_cmd(3) = inf;
%           u_stick_cmd(4) = cp1(1,1);
%           
%           % set trim values to inf here, trim will be set by slider
%           % callback
%           trim_scaled(1:4) = inf;
%           send_stick_cmd(u_stick_cmd,trim_scaled,...
%               sTrainerBox,stick_lim,pax,textDispVec);
% 
%      end  
%    end
   
disp('exiting l joy');

end