function r_joy(h,sTrainerBox,stick_lim,pax,textDispVec) % h = hnadle to axes
disp('entering r_joy');
delete(findall(h,'type','text'));
% disp(gcf);
set (gcf, 'KeyPressFcn', {@kpcb,sTrainerBox,stick_lim,pax,textDispVec},'units','normalized');
% 
%     function kpcb(src,evnt,pax,sTrainerBox)
%       
%         keypressed = evnt.Key;
%        switch( keypressed)
%            case {'uparrow'}
%                % update marker pos
%                cp1 =[pax(2).XData, (pax(2).YData+0.05) ];
%                wbmcb(pax,cp1,sTrainerBox);
%                  
%            
%            case {'downarrow'}
%                % update marker pos
%                cp1 =[pax(2).XData, (pax(2).YData-0.05) ];
%                wbmcb(pax,cp1,sTrainerBox);
%                
%            case {'rightarrow'}
%                % update marker pos
%                cp1 =[(pax(2).XData+0.05), pax(2).YData ];
%                wbmcb(pax,cp1,sTrainerBox);
%                
%            case {'leftarrow'}
%                % update marker pos
%                cp1 =[(pax(2).XData-0.05), pax(2).YData ];
%                wbmcb(pax,cp1,sTrainerBox);
%           
%            case {'shift'}
%                % update marker pos
%                cp1 =[0, 0 ];
%                wbmcb(pax,cp1,sTrainerBox);
%                
%        end
%       
%       function wbmcb(pax,cp1,sTrainerBox)
%           cp1(1,1)= max(-1,min(1,cp1(1,1)));
%           cp1(1,2)= max(-1,min(1,cp1(1,2)));
%           
%           cp2 = cp1
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
   
disp('exiting r_joy');

end