function wbdcb(src,evnt,handles,textDispVec)
ax = gca;%handles.axes5;%********very important line*****don't erase
                        %sets the origin of figure to origin of right polar plot
      if strcmp(get(src,'SelectionType'),'normal')
          cp1 = get(ax,'CurrentPoint')
          if  (cp1(1,1)>=-0.1 && cp1(1,1)<=0.1)&&(cp1(1,2)>=-0.1 && cp1(1,2)<=0.1)   
                set(src,'WindowButtonMotionFcn',{@wbmcb,handles,textDispVec,ax})      
          end
      end
end
