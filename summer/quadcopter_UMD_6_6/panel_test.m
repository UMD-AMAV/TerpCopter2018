function varargout = panel_test(varargin)

% Begin initialization code - DO NOT EDIT

disp('executing panel_test');
%% 
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @panel_test_OpeningFcn, ...
                   'gui_OutputFcn',  @panel_test_OutputFcn, ...
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


% --- Executes just before panel_test is made visible.
function panel_test_OpeningFcn(hObject, eventdata, handles, varargin)

delete(instrfindall) % close com ports
disp('executing panel_test_opening_fcn');
clear send_stick_cmd; % clearing persistent variables
clear yaw_controller;
handles.sTrainerBox = serial('COM3');%serial('COM5');
handles.sTrainerBox.BaudRate = 57600;
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

% set slider positions
handles.slider2.Value = trim(1);
handles.slider6.Value = trim(2);
handles.slider5.Value = trim(3);
handles.slider3.Value = trim(4);

% stick limits as set in the transmitter
handles.stick_lim = [147; 147; 147; 147];

% trim limits as set in the transmitter
handles.trim_lim = [43; 43; 43; 43];

trim_scaled = trim.*(handles.trim_lim./handles.stick_lim);

textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 

%create polar plots
handles.pax(1) = polar(handles.axes4,deg2rad(270),1,'ro');
set(handles.pax(1),'MarkerSize',16,'MarkerFaceColor','r');
handles.pax(2) = polar(handles.axes5,deg2rad(0),0,'bo');
set(handles.pax(2),'MarkerSize',16,'MarkerFaceColor','b');
delete(findall(handles.axes4,'type','text'));
delete(findall(handles.axes5,'type','text'));
set (gcf, 'KeyPressFcn', {@kpcb,handles,textDispVec},'units','normalized');
set (gcf, 'WindowButtonDownFcn', {@wbdcb,handles,textDispVec});
set (gcf, 'WindowButtonUpFcn', {@wbucb,handles,textDispVec});


pause(2); % initially arduino gives high values to the channels
% wait for arduino to initialise

send_stick_cmd(u_stick_cmd,trim_scaled,handles.sTrainerBox,...
               handles.stick_lim,handles.pax,textDispVec);

% set yaw_controller radio button off
 handles.yaw_control_radio.Value  =0; 
 
%%--------initialise ros------------
if(~robotics.ros.internal.Global.isNodeActive)
        rosinit;
end
% Choose default command line output for panel_test
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

%%
% UIWAIT makes panel_test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = panel_test_OutputFcn(hObject, eventdata, handles) 
disp('executing outputfcn');
% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
    % thrustDisplay trim
u_stick_cmd(1:4) = inf;
trim_scaled(2:4) = inf;
trim_scaled(1) = hObject.Value*handles.trim_lim(1)/handles.stick_lim(1);
textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 
send_stick_cmd(u_stick_cmd,trim_scaled,...
              handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec);


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
trim_scaled(1:3) = inf;
trim_scaled(4) = hObject.Value*handles.trim_lim(4)/handles.stick_lim(4);
textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 

  send_stick_cmd(u_stick_cmd,trim_scaled,...
              handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec);



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



% --- Executes during object creation, after setting all properties.
function axes4_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate axes4
% handles


% --- Executes during object creation, after setting all properties.
function axes5_CreateFcn(hObject, eventdata, handles)
% Hint: place code in OpeningFcn to populate axes5


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% pitchDisplay slider
u_stick_cmd(1:4) = inf;
trim_scaled(1:4) = inf;
trim_scaled(3) = hObject.Value*handles.trim_lim(3)/handles.stick_lim(3);
textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 
send_stick_cmd(u_stick_cmd,trim_scaled,...
handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec);

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
trim_scaled(1:4) = inf;
trim_scaled(2) = hObject.Value*handles.trim_lim(2)/handles.stick_lim(2);
textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 
 send_stick_cmd(u_stick_cmd,trim_scaled,...
handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec);



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
disp('BYE'); 
rosshutdown
delete(hObject);



function thrustDisplay_Callback(hObject, eventdata, handles)
input = str2double(get(hObject,'String'));
if isnan(input)
   errordlg('Invalid Input','Invalid Input','modal')
   uicontrol(hObject)
   return

elseif input>(-handles.stick_lim(1)+handles.trim_lim(1))        
       input = handles.trim_lim(1);
    
elseif input<(-handles.stick_lim(1)-handles.trim_lim(1))
       input = -handles.trim_lim(1);
else
       input = input +handles.stick_lim(1);
end
% send command
u_stick_cmd(1:4) = inf;
trim_scaled(1) = input/handles.stick_lim(1);
trim_scaled(2:4) = inf;
% set slider position
temp = input/handles.trim_lim(1);
temp = max(-1,min(1,temp)); 
handles.slider2.Value = temp;

textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 
send_stick_cmd(u_stick_cmd,trim_scaled,...
handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec); 
   

% --- Executes during object creation, after setting all properties.
function thrustDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function rollDisplay_Callback(hObject, eventdata, handles)
input = str2double(get(hObject,'String'));
if isnan(input)
  errordlg('Invalid Input','Invalid Input','modal')
  uicontrol(hObject)
  return
elseif input>(handles.trim_lim(2))
       input = handles.trim_lim(2);
elseif input<(-handles.trim_lim(2))
       input = -handles.trim_lim(2);
end
  % send command
   u_stick_cmd(1:4) = inf;
   trim_scaled(1:4) = inf;
   trim_scaled(2) = input/handles.stick_lim(2);
   % set slider position
   temp = input/handles.trim_lim(2);
   temp = max(-1,min(1,temp)); 
   handles.slider6.Value = temp;

   textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 

   send_stick_cmd(u_stick_cmd,trim_scaled,...
   handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec); 


% --- Executes during object creation, after setting all properties.
function rollDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pitchDisplay_Callback(hObject, eventdata, handles)
input = str2double(get(hObject,'String'));
if isnan(input)
  errordlg('Invalid Input','Invalid Input','modal')
  uicontrol(hObject)
  return
elseif input>(handles.trim_lim(3))
       input = handles.trim_lim(3);
elseif input<(-handles.trim_lim(3))
       input = -handles.trim_lim(3);
end
  % send command
   u_stick_cmd(1:4) = inf;
   trim_scaled(1:4) = inf;
   trim_scaled(3) = input/handles.stick_lim(3);
   % set slider position
   temp = input/handles.trim_lim(3);
   temp = max(-1,min(1,temp)); 
   handles.slider5.Value = temp;

   textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 

   send_stick_cmd(u_stick_cmd,trim_scaled,...
   handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec); 


% --- Executes during object creation, after setting all properties.
function pitchDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yawDisplay_Callback(hObject, eventdata, handles)
input = str2double(get(hObject,'String'));
if isnan(input)
  errordlg('Invalid Input','Invalid Input','modal')
  uicontrol(hObject)
  return
elseif input>(handles.trim_lim(4))
       input = handles.trim_lim(4);
elseif input<(-handles.trim_lim(4))
       input = -handles.trim_lim(4);
end
  % send command
   u_stick_cmd(1:4) = inf;
   trim_scaled(1:4) = inf;
   trim_scaled(4) = input/handles.stick_lim(4);
   % set slider position
   temp = input/handles.trim_lim(4);
   temp = max(-1,min(1,temp)); 
   handles.slider3.Value = temp;

   textDispVec = [handles.thrustDisplay handles.rollDisplay...
               handles.pitchDisplay handles.yawDisplay]; 

   send_stick_cmd(u_stick_cmd,trim_scaled,...
   handles.sTrainerBox,handles.stick_lim,handles.pax,textDispVec); 

% --- Executes during object creation, after setting all properties.
function yawDisplay_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in yaw_control_radio.
function yaw_control_radio_Callback(hObject, eventdata, handles)
run_ros_node(handles);
    
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
