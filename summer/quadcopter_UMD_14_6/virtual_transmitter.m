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


% --- Executes just before virtual_transmitter is made visible.
function virtual_transmitter_OpeningFcn(hObject, eventdata, handles, varargin)
% addpath(utilities);
delete(instrfindall) % close com ports
disp('executing virtual_transmitter_opening_fcn');
clear send_stick_cmd; % clearing persistent variables
clear controller_fcn;
clear update_ros_data;
% load parameters
param;
handles.sTrainerBox = serial(com_port);%serial('COM5');
handles.sTrainerBox.BaudRate = baud_rate;
handles.sTrainerBox.terminator = '';
fopen(handles.sTrainerBox);
disp( 'com port initialised');

% set initial stick commands
u_stick_cmd(1) = -1; % thrust 
u_stick_cmd(2) = 0;  % roll
u_stick_cmd(3) = 0;  % pitch
u_stick_cmd(4) = 0;  % yaw rat

%load trim values from file
% trim values lie between -1 and 1 as slider moves between these values
fname = 'trim.txt';
fid = fopen(fname,'r');
trim = dlmread(fname);
fclose(fid);

%load gain values from file
% TODO make sliders for gains
fname = 'gains.txt';
fid = fopen(fname,'r');
gains = dlmread(fname);
fclose(fid);
set(handles.k_h_editTextBox,'String',num2str(gains(1)));
set(handles.k_si_editTextBox,'String',num2str(gains(2)));

% set slider positions
handles.slider2.Value = trim(1);
handles.slider6.Value = trim(2);
handles.slider5.Value = trim(3);
handles.slider3.Value = trim(4);

% stick limits as set in the transmitter
handles.stick_lim = stick_lim;

% trim limits as set in the transmitter
handles.trim_lim = trim_lim;

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


pause(2); % initially arduino gives high values to the channels
% wait for arduino to initialise
send_stick_cmd(u_stick_cmd,trim,handles);

% set yaw_controller radio button off
 handles.yaw_control_radio.Value  =0; 
 
%%--------initialise ros------------
%%******************************************change to ip of ros master*****???????????
if(~robotics.ros.internal.Global.isNodeActive)
 rosinit(ros_master_ip); % for CBCI
end
global imu_yawsub t_c;
imu_yawsub = rossubscriber('/mavros/imu/data');
pause(2) % wait for subscriber to be able to receive messages
t_c = timer('executionMode','fixedrate','TimerFcn',{@controller_fcn,handles},'Period',time_period);
start(t_c);
%------------------------------------

% Choose default command line output for virtual_transmitter
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

%
% UIWAIT makes virtual_transmitter wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = virtual_transmitter_OutputFcn(hObject, eventdata, handles) 
disp('executing outputfcn');
% Get default command line output from handles structure
varargout{1} = handles.output;


 %--- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate axes4
% handles


% --- Executes during object creation, after setting all properties.
function axes5_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate axes5


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% thrustDisplay trim
u_stick_cmd(1:4) = inf;
trim(2:4) = inf;
trim(1) = hObject.Value;
send_stick_cmd(u_stick_cmd,trim,handles);

% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject,eventdata, handles)
hObject.Min = -1;
pos = hObject.Position;
l = pos(3); h = pos(4)/5;
pos1 = [(pos(1)-l), (pos(2)+pos(4)/2)-h/4,l,h];
pos2 = [(pos(1)+l), (pos(2)+pos(4)/2)-h/4,l,h];
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
   hObject.Units,'Position',pos1,'String','--',...
   'BackgroundColor',hObject.Parent.BackgroundColor);
uicontrol('Parent',hObject.Parent,'Style','text','Units',...
   hObject.Units,'Position',pos2,'String','--',...
   'BackgroundColor',hObject.Parent.BackgroundColor);

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
%yawDisplay slider
u_stick_cmd(1:4) = inf;
trim(1:3) = inf;
trim(4)  = hObject.Value;
send_stick_cmd(u_stick_cmd,trim,handles);


% --- Executes during object creation, after setting all properties.
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

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% pitchDisplay slider
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;
trim(3) = hObject.Value;
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

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
   set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider6_Callback(hObject, eventdata, handles)
% rollDisplay slider
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;
trim(2) = hObject.Value;
send_stick_cmd(u_stick_cmd,trim,handles);

% --- Executes during object creation, after setting all properties.
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

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function thrustDisplay_Callback(hObject, eventdata, handles)
 input = str2double(get(hObject,'String'));
u_stick_cmd(1:4) = inf;
trim(1:4) = inf;

if isnan(input)
   errordlg('Invalid Input','Invalid Input','modal')
   uicontrol(hObject)
   return

elseif input>(handles.stick_lim(1)+handles.trim_lim(1))        
       handles.u_stick_cmd(1) = handles.stick_lim(1);
       trim(1) = handles.trim_lim(1);
       
elseif input<(-handles.stick_lim(1)-handles.trim_lim(1))
       handles.u_stick_cmd(1) = -handles.stick_lim(1);
       trim(1) = -handles.trim_lim(1);

elseif input>(handles.stick_lim(1))        
       handles.u_stick_cmd(1) = handles.stick_lim(1);
       trim(1) = input-handles.stick_lim(1);
       
elseif input<(-handles.stick_lim(1))
       handles.u_stick_cmd(1) = -handles.stick_lim(1);
       trim(1) = input+handles.stick_lim(1);
else
       u_stick_cmd(1) = input;
end
% set slider position
if(trim(1)) ~=inf
  trim(1) = trim(1)/handles.trim_lim(1);
  trim(1) = max(-1,min(1,trim(1)));
  handles.slider2.Value = trim(1);
end

u_stick_cmd(1) = u_stick_cmd(1)/handles.stick_lim(1);
u_stick_cmd(1) = max(-1,min(1,u_stick_cmd(1))); 
% send command
send_stick_cmd(u_stick_cmd,trim,handles);
   

% --- Executes during object creation, after setting all properties.
function thrustDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rollDisplay_Callback(hObject, eventdata, handles)
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
% send command
send_stick_cmd(u_stick_cmd,trim,handles);


% --- Executes during object creation, after setting all properties.
function rollDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pitchDisplay_Callback(hObject, eventdata, handles)
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
% send command
send_stick_cmd(u_stick_cmd,trim,handles);


% --- Executes during object creation, after setting all properties.
function pitchDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function yawDisplay_Callback(hObject, eventdata, handles)
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
% send command
send_stick_cmd(u_stick_cmd,trim,handles);

% --- Executes during object creation, after setting all properties.
function yawDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in yaw_control_radio.
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


% --- Executes on button press in altitude_control_radio.
function altitude_control_radio_Callback(hObject, eventdata, handles)
run_ros_node(handles);

function k_h_editTextBox_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function k_h_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function h_des_editTextBox_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function h_des_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function h_a_editTextBox_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function h_a_editTextBox_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
 function figure1_CloseRequestFcn(hObject, eventdata, handles)
%display a question dialog box 
 selection = questdlg('exit?','Close Request Function','Yes','No','Yes'); 
switch selection 
      case 'Yes'     
      case 'No'
       return 
end    
% save trim values to file 
% save thrustDisplay trim to zero always
trim = [0; handles.slider6.Value;...
         handles.slider5.Value; handles.slider3.Value];
fname = 'trim.txt';
fid = fopen(fname,'w');
dlmwrite(fname,trim);
fclose(fid);
% fclose(handles.sTrainerBox);
% throws an error sometimes
fname = 'gains.txt';
gains = [0;str2double(get(handles.k_si_editTextBox,'String'))];
fid = fopen(fname,'w');
dlmwrite(fname,gains);
fclose(fid);
% clear global variables
global t_c;
if(t_c.Running),stop(t_c);end
delete(t_c);
clear global t_c;
clear global imu_yawsub;
% close all; % close any open windows
disp('BYE'); 
rosshutdown
delete(hObject);


% --- Executes on button press in togglebutton2.
function togglebutton2_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of togglebutton2
