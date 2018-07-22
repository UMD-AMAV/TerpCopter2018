function wbucb(src,evnt,handles)
% THIS FUNCTION IS CALLED WHEN USER RELEASES THE LEFT MOUSE BUTTON 
% INPUTS:
%   src:     handle to the figure window
%   evnt:    structure containing key press information 
%   handles: a structure containing handles to GUI objects
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

set(src,'WindowButtonMotionFcn','');
u_stick_cmd(1) = NaN; 
u_stick_cmd(2) = 0;
u_stick_cmd(3) = 0;
u_stick_cmd(4) = NaN;
          
trim(1:4) = NaN;
disp('calling send_stick_cmd()');
send_stick_cmd(u_stick_cmd,trim,handles);

end