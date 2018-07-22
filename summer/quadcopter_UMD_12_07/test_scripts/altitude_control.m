function altitude_control(src,msg)
disp('altitude control function');
disp(msg.Data);
% Control script
% Loop over an input variable and create several MATLABs
% for param = 1:2
%   funcstr = 'C:\Program Files\MATLAB\R2018a\bin\matlab -nodisplay -nosplash -r ';
%   scrstr = ['"x=',num2str(param),';yaw_rate_control;exit"'];
%   command = [funcstr, scrstr,'&'];
%   system(command);
% end
end