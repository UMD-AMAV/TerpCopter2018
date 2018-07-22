function wbdcb(src,evnt,handles)
% THIS FUNCTION IS CALLED WHEN USER PRESSES MOUSE BUTTON 
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

ax = gca;%handles.axes5;%********very important line*****don't erase
                        %sets the origin of figure to origin of right polar plot
      if strcmp(get(src,'SelectionType'),'normal')
          cp1 = get(ax,'CurrentPoint');
          if  (cp1(1,1)>=-0.1 && cp1(1,1)<=0.1)&&(cp1(1,2)>=-0.1 && cp1(1,2)<=0.1)   
                set(src,'WindowButtonMotionFcn',{@wbmcb,handles,ax})      
          end
      end
end
