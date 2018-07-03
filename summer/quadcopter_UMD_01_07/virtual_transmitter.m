function varargout = virtual_transmitter(varargin)
% Begin initialization code - DO NOT EDIT
disp('executing virtual_transmitter');
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @virtual_transmitter_OpeningFcn, ...
                   'gui_OutputFcn',  @virtual_transmitter_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


%--- Executes just before virtual_transmitter is made visible.
function virtual_transmitter_OpeningFcn(hObject, eventdata, handles, varargin)
%addpath(utilities);
%close com ports
delete(instrfindall) 
disp('executing virtual_transmitter_opening_fcn');
%clearing persistent variables
clear send_stick_cmd; 
clear controller_fcn;
clear disp_sensor_data;
%load parameters
param;
handles.sTrainerBox = serial(com_port);
handles.sTrainerBox.BaudRate = baud_rate;
handles.sTrainerBox.terminator = '';
fopen(handles.sTrainerBox);
disp( 'com port initialised');

%stick limits as set in the transmitter
handles.stick_lim = stick_lim;

%trim limits as set in the transmitter
handles.trim_lim = trim_lim;

%set initial stick commands
u_stick_cmd(1) = -1; % thrust 
u_stick_cmd(2) = 0;  % roll
u_stick_cmd(3) = 0;  % pitch
u_stick_cmd(4) = 0;  % yaw rat

%load trim values from file
%trim values lie between -1 and 1 as slider moves between these values
fname = 'trim.txt';
fid = fopen(fname,'r');
trim = dlmread(fname);
fclose(fid);

%load gain values from file
fname = 'gains.txt';
fid = fopen(fname,'r');
gains = dlmread(fname);
fclose(fid);
set(handles.k_h_editTextBox,'String',num2str(gains(1)));
set(handles.k_h_d_textbox,'String',num2str(gains(2)));
set(handles.k_h_i_textbox,'String',num2str(gains(3)));
set(handles.k_h_textbox,'String',num2str(gains(4)));
set(handles.k_si_editTextBox,'String',num2str(gains(5)));

% gain sliders
handles.kph_slider.Value = gains(1);
handles.kdh_slider.Value = gains(2);
handles.kih_slider.Value = gains(3);
handles.kh_slider.Value = gains(4);

% set slider step size
set(handles.kph_slider, 'SliderStep', [.001  .001 ]);
set(handles.kdh_slider, 'SliderStep', [.001  .001 ]);
set(handles.kih_slider, 'SliderStep', [.001  .001 ]);
set(handles.kh_slider, 'SliderStep', [.001  .001 ]);

%set slider positions
handles.slider2.Value = trim(1);
handles.slider6.Value = trim(2);
handles.slider5.Value = trim(3);
handles.slider3.Value = trim(4);

%set slider textbox values.
set(handles.thrust_trim_textbox,'String', num2str(trim(1)*trim_lim(1)));
set(handles.roll_trim_textbox,'String', num2str(trim(2)*trim_lim(2)));
set(handles.pitch_trim_textbox,'String', num2str(trim(3)*trim_lim(3)));
set(handles.yaw_trim_textbox,'String', num2str(trim(4)*trim_lim(4)));


% set slider step size
set(handles.slider2, 'SliderStep', [(.5/trim_lim(1))  (1/trim_lim(1)) ]);
set(handles.slider6, 'SliderStep', [.5/trim_lim(2)  1/trim_lim(2) ]);
set(handles.slider5, 'SliderStep', [.5/trim_lim(3)  1/trim_lim(3) ]);
set(handles.slider3, 'SliderStep', [.5/trim_lim(4)  1/trim_lim(4) ]);

%create polar plots
handles.pax(1) = polar(handles.axes4,deg2rad(270),1,'ro');
set(handles.pax(1),'MarkerSize',16,'MarkerFaceColor','r');
handles.pax(2) = polar(handles.axes5,deg2rad(0),0,'bo');
set(handles.pax(2),'MarkerSize',16,'MarkerFaceColor','b');
delete(findall(handles.axes4,'type','text'));
delete(findall(handles.axes5,'type','text'));
set (gcf, 'KeyPressFcn', {@kpcb,handles},'units','normalized');
set (gcf, 'WindowButtonDownFcn', {@wbdcb,handles});
set (gcf, 'WindowButtonUpFcn', {@wbucb,handles});

%initially arduino gives high values to the channels
% wait for arduino to initialise
pause(2); 
send_stick_cmd(u_stick_cmd,trim,handles);

%set yaw_controller radio button off
 handles.yaw_control_radio.Value  =0; 
%set h_controller radio button off
 handles.h_control_radio.Value  =0; 

 
 
%--------initialise ros------------
if(~robotics.ros.internal.Global.isNodeActive)
 rosinit(ros_master_ip); % for CBCI
end
global imu_yawsub t_c lidarsub t_clock;
imu_yawsub = rossubscriber('/mavros/imu/data');
lidarsub = rossubscriber('/terarangerone');
%wait for subscriber to be able to receive messages
pause(2);
t_clock = clock;
t_c = timer('ExecutionMode','fixedRate','TimerFcn',{@controller_fcn2,handles},'Period',time_period);
start(t_c);
%------------------------------------

%Choose default command line output for virtual_transmitter
handles.output = hObject;
%Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = virtual_transmitter_OutputFcn(hObject, eventdata,handles) 
disp('executing outputfcn');
% Get default command line output from handles structure
varargout{1} = handles.output;


%----------- callbacks functions for gui objects-------------------------- 
%-------------------------------------------------------------------------

%-- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate axes4
% handles


% --- Executes during object creation, after setting all properties.
function axes5_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate axes5


%********************throttle objects************************** 
function slider2_Callback(hObject, eventdata, handles)
u_stick_cmd(1:4) = inf;
trim(2:4) = inf;
trim(1) = hObject.Value;
%set throttle trim text box value
set(handles.thrust_trim_textbox,'String',trim(1)*handles.trim_lim(1));
send_stick_cmd(u_stick_cmd,trim,handles);


function slider2_CreateFcn(hObject,eventdata, handles)
hObject.Min = -1;
pos = hObject.Position;
l = pos(3); h = pos(4)/5;
pos1 = [(pos(1)-l), (pos(2)+pos(4)/2),l,h];
pos2 = [(pos(1)+l), (pos(2)+pos(4)/2),l,h];
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
   hObject.Units,'Position',pos1,'String','--',...
   'BackgroundColor',hObject.Parent.BackgroundColor);
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
   hObject.Units,'Position',pos2,'String','--',...
   'BackgroundColor',hObject.Parent.BackgroundColor);
if isequal(get(hObject,'BackgroundColor'), ...
   get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function thrust_trim_textbox_Callback(hObject, eventdata, handles)
input = str2double(get(hObject,'String'));
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;

if isnan(input)
   errordlg('Invalid Input','Invalid Input','modal')
   uicontrol(hObject)
   return

elseif input>(handles.trim_lim(1))        
       trim(1) = handles.trim_lim(1);
       
elseif input<(-handles.trim_lim(1))
       trim(1) = -handles.trim_lim(1);
else
       trim(1) = input;
end
% set slider position
trim(1) = trim(1)/handles.trim_lim(1);
trim(1) = max(-1,min(1,trim(1))); 
handles.slider2.Value = trim(1);
set(hObject,'String',trim(1)*handles.trim_lim(1));
% send command
send_stick_cmd(u_stick_cmd,trim,handles);

function thrust_trim_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function thrustDisplay_Callback(hObject, eventdata, handles)
function thrustDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%***************roll objects******************************************
function slider6_Callback(hObject, eventdata, handles)
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;
trim(2) = hObject.Value;
%set trim text box value
set(handles.roll_trim_textbox,'String',trim(2)*handles.trim_lim(2));
send_stick_cmd(u_stick_cmd,trim,handles);

function slider6_CreateFcn(hObject, eventdata, handles)
hObject.Min = -1;
pos = hObject.Position;
l = pos(3)/5; h = pos(4);
pos1 = [(pos(1)+pos(3)/2-l/2.5), (pos(2)-pos(4)),l,h];
pos2 = [(pos(1)+pos(3)/2-l/2.5), (pos(2)+1.1*pos(4)),l,h];
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
hObject.Units,'Position',pos1,'String','|',...
'BackgroundColor',hObject.Parent.BackgroundColor);
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
hObject.Units,'Position',pos2,'String','|',...
'BackgroundColor',hObject.Parent.BackgroundColor);
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function roll_trim_textbox_Callback(hObject, eventdata, handles)
input = str2double(get(hObject,'String'));
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;
disp(input);
if isnan(input)
   errordlg('Invalid Input','Invalid Input','modal')
   uicontrol(hObject)
   return

elseif input>(handles.trim_lim(2))        
       trim(2) = handles.trim_lim(2);
       
elseif input<(-handles.trim_lim(2))
       trim(2) = -handles.trim_lim(2);
else
       trim(2) = input;
end
% set slider position
trim(2) = trim(2)/handles.trim_lim(2);
trim(2) = max(-1,min(1,trim(2))); 
handles.slider6.Value = trim(2);
set(hObject,'String',trim(2)*handles.trim_lim(2));
% send command
send_stick_cmd(u_stick_cmd,trim,handles);

function roll_trim_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rollDisplay_Callback(hObject, eventdata, handles)
function rollDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%*******************pitch objects************************************
function slider5_Callback(hObject, eventdata, handles)
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;
trim(3) = hObject.Value;
%set trim text box value
set(handles.pitch_trim_textbox,'String',trim(3)*handles.trim_lim(3));
send_stick_cmd(u_stick_cmd,trim,handles);

% --- Executes during object creation, after setting all properties.
function slider5_CreateFcn(hObject, eventdata, handles)
hObject.Min = -1;
pos = hObject.Position;
l = pos(3); h = pos(4)/5;
pos1 = [(pos(1)-l), (pos(2)+pos(4)/2-h/4),l,h];
pos2 = [(pos(1)+l), (pos(2)+pos(4)/2-h/4),l,h];
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
hObject.Units,'Position',pos1,'String','--',...
'BackgroundColor',hObject.Parent.BackgroundColor);
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
hObject.Units,'Position',pos2,'String','--',...
'BackgroundColor',hObject.Parent.BackgroundColor);
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function pitch_trim_textbox_Callback(hObject, eventdata, handles)
input = str2double(get(hObject,'String'));
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;

if isnan(input)
   errordlg('Invalid Input','Invalid Input','modal')
   uicontrol(hObject)
   return

elseif input>(handles.trim_lim(3))        
       trim(3) = handles.trim_lim(3);
       
elseif input<(-handles.trim_lim(3))
       trim(3) = -handles.trim_lim(3);
else
       trim(3) = input;
end
% set slider position
trim(3) = trim(3)/handles.trim_lim(3);
trim(3) = max(-1,min(1,trim(3))); 
handles.slider5.Value = trim(3);
set(hObject,'String',trim(3)*handles.trim_lim(3));
% send command
send_stick_cmd(u_stick_cmd,trim,handles);

function pitch_trim_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function pitchDisplay_Callback(hObject, eventdata, handles)
function pitchDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%***********************yaw objects*************************************
function slider3_Callback(hObject, eventdata, handles)
u_stick_cmd(1:4) = inf;
trim(1:3) = inf;
trim(4)  = hObject.Value;
%set trim text box value
set(handles.yaw_trim_textbox,'String',trim(4)*handles.trim_lim(4));
send_stick_cmd(u_stick_cmd,trim,handles);


function slider3_CreateFcn(hObject, eventdata, handles)
hObject.Min = -1;
pos = hObject.Position;
l = pos(3)/5; h = pos(4);
pos1 = [(pos(1)+pos(3)/2-l/2.5), (pos(2)-pos(4)),l,h];
pos2 = [(pos(1)+pos(3)/2-l/2.5), (pos(2)+1.1*pos(4)),l,h];
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
   hObject.Units,'Position',pos1,'String','|',...
   'BackgroundColor',hObject.Parent.BackgroundColor);
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
   hObject.Units,'Position',pos2,'String','|',...
   'BackgroundColor',hObject.Parent.BackgroundColor);
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function yaw_trim_textbox_Callback(hObject, eventdata, handles)
input = str2double(get(hObject,'String'));
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;

if isnan(input)
   errordlg('Invalid Input','Invalid Input','modal')
   uicontrol(hObject)
   return

elseif input>(handles.trim_lim(4))        
       trim(4) = handles.trim_lim(4);
       
elseif input<(-handles.trim_lim(4))
       trim(4) = -handles.trim_lim(4);
else
       trim(4) = input;
end
% set slider position
trim(4) = trim(4)/handles.trim_lim(4);
trim(4) = max(-1,min(1,trim(4))); 
handles.slider3.Value = trim(4);
set(hObject,'String',trim(4)*handles.trim_lim(4));
% send command
send_stick_cmd(u_stick_cmd,trim,handles);


function yaw_trim_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function yawDisplay_Callback(hObject, eventdata, handles)
function yawDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%function thrustDisplay_Callback(hObject, eventdata, handles)
% input = str2double(get(hObject,'String'));
% u_stick_cmd(1:4) = inf;
% trim(1:4) = inf;
% 
% if isnan(input)
%    errordlg('Invalid Input','Invalid Input','modal')
%    uicontrol(hObject)
%    return
% 
% elseif input>(handles.stick_lim(1)+handles.trim_lim(1))        
%        handles.u_stick_cmd(1) = handles.stick_lim(1);
%        trim(1) = handles.trim_lim(1);
%        
% elseif input<(-handles.stick_lim(1)-handles.trim_lim(1))
%        handles.u_stick_cmd(1) = -handles.stick_lim(1);
%        trim(1) = -handles.trim_lim(1);
% 
% elseif input>(handles.stick_lim(1))        
%        handles.u_stick_cmd(1) = handles.stick_lim(1);
%        trim(1) = input-handles.stick_lim(1);
%        
% elseif input<(-handles.stick_lim(1))
%        handles.u_stick_cmd(1) = -handles.stick_lim(1);
%        trim(1) = input+handles.stick_lim(1);
% else
%        u_stick_cmd(1) = input;
% end
% % set slider position
% if(trim(1)) ~=inf
%   trim(1) = trim(1)/handles.trim_lim(1);
%   trim(1) = max(-1,min(1,trim(1)));
%   handles.slider2.Value = trim(1);
% end
% 
% u_stick_cmd(1) = u_stick_cmd(1)/handles.stick_lim(1);
% u_stick_cmd(1) = max(-1,min(1,u_stick_cmd(1))); 
% % send command
% send_stick_cmd(u_stick_cmd,trim,handles);
   

% --- Executes during object creation, after setting all properties.

%**********************yaw controller functions*************************
function yaw_control_radio_Callback(hObject, eventdata, handles)

function k_si_editTextBox_Callback(hObject, eventdata, handles)

function k_si_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function si_des_editTextBox_Callback(hObject, eventdata, handles)

function si_des_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function si_a_editTextBox_Callback(hObject, eventdata, handles)

function si_a_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%**********************altitude controller functions**********************
function altitude_control_radio_Callback(hObject, eventdata, handles)

function k_h_editTextBox_Callback(hObject, eventdata, handles)
handles.kph_slider.Value = str2double(get(hObject,'String'));  

function k_h_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function k_h_d_textbox_Callback(hObject, eventdata, handles)
handles.kdh_slider.Value = str2double(get(hObject,'String'));

function k_h_d_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function k_h_i_textbox_Callback(hObject, eventdata, handles)
handles.kih_slider.Value = str2double(get(hObject,'String'));
   
function k_h_i_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function k_h_textbox_Callback(hObject, eventdata, handles)
handles.kh_slider.Value = str2double(get(hObject,'String'));

function k_h_textbox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function h_des_editTextBox_Callback(hObject, eventdata, handles)
function h_des_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function h_a_editTextBox_Callback(hObject, eventdata, handles)
function h_a_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



%*************altitude gain slider call backs**********************
function kph_slider_Callback(hObject, eventdata, handles)
set(handles.k_h_editTextBox,'String',num2str(hObject.Value));


function kph_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function kdh_slider_Callback(hObject, eventdata, handles)
set(handles.k_h_d_textbox,'String',num2str(hObject.Value));


function kdh_slider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function kih_slider_Callback(hObject, eventdata, handles)
set(handles.k_h_i_textbox,'String',num2str(hObject.Value));

function kih_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function kh_slider_Callback(hObject, eventdata, handles)
set(handles.k_h_textbox,'String',num2str(hObject.Value));

function kh_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


%**********close figure request function*****************************
 function figure1_CloseRequestFcn(hObject, eventdata, handles)
%display a question dialog box 
 selection = questdlg('exit?','Close Request Function','Yes','No','Yes'); 
switch selection 
      case 'Yes'     
      case 'No'
       return 
end
%save trim values to file
trim = [handles.slider2.Value; handles.slider6.Value;...
         handles.slider5.Value; handles.slider3.Value];
fname = 'trim.txt';
fid = fopen(fname,'w');
dlmwrite(fname,trim);
fclose(fid);
%fclose(handles.sTrainerBox);
%throws an error sometimes
% save controller gains to file
fname = 'gains.txt';
gains = [str2double(get(handles.k_h_editTextBox,'String'));...
         str2double(get(handles.k_h_d_textbox,'String'));
         str2double(get(handles.k_h_i_textbox,'String'));
         str2double(get(handles.k_h_textbox,'String'));
         str2double(get(handles.k_si_editTextBox,'String'))];
fid = fopen(fname,'w');
dlmwrite(fname,gains);
fclose(fid);

%clear global variables
global t_c;
if(t_c.Running),stop(t_c);end
delete(t_c);
clear global t_c;
clear global imu_yawsub;
clear global lidarsub;

%close all; % close any open windows
disp('BYE'); 

% close lidar data file
% fclose(handles.fid);

rosshutdown;
delete(hObject);
