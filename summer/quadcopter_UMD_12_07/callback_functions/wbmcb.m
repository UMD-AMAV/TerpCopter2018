function wbmcb(src,evnt,handles,ax)
% THIS FUNCTION IS CALLED WHEN USER LEFT CLICKS AND MOVES THE MOUSE 
% INPUTS:
%   src:     handle to the figure window
%   evnt:    structure containing key press information 
%   handles: a structure containing handles to GUI objects
%   ax:      hnadle to the polar plots
%
% OUTPUT:
%   none
%
% AUTHOR: SHUBHAM JENA
% AFFILIATION : UNIVERSITY OF MARYLAND 
% EMAIL : jena_shubham@iitkgp.ac.in

% THE WORK (AS DEFINED BELOW) IS PROVIDED UNDER THE TERMS OF THE GPLv3 LICENSE
% THE WORK IS PROTECTED BY COPYRIGHT AND/OR OTHER APPLICABLE LAW. ANY USE OF
% THE WORK OTHER THAN AS AUTHORIZED UNDER THIS LICENSE OR COPYRIGHT LAW IS 
% PROHIBITED.
%  
% BY EXERCISING ANY RIGHTS TO THE WORK PROVIDED HERE, YOU ACCEPT AND AGREE TO
% BE BOUND BY THE TERMS OF THIS LICENSE. THE LICENSOR GRANTS YOU THE RIGHTS
% CONTAINED HERE IN CONSIDERATION OF YOUR ACCEPTANCE OF SUCH TERMS AND
% CONDITIONS.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

          scale_down_factor = .2;
          %  to reduce mouse sensitivity
          cp = (get(ax,'CurrentPoint'))*scale_down_factor;
          cp(1,1)= max(-1,min(1,cp(1,1)));
          cp(1,2)= max(-1,min(1,cp(1,2)));
          
          u_stick_cmd(1) = NaN; 
          u_stick_cmd(2) = cp(1,1);
          u_stick_cmd(3) = cp(1,2);
          u_stick_cmd(4) = NaN;
          
          trim(1:4) = NaN;
          disp('calling send_stick_cmd()');
          send_stick_cmd(u_stick_cmd,trim,handles);
end  
