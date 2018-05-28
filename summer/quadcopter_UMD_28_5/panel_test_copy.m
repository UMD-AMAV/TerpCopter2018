function varargout = panel_test(varargin)

% Begin initialization code - DO NOT EDIT
%% my code
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

% stick limits as set in the transmitter
handles.stick_lim = [147; 147; 147; 147];
% throttle_max = 147; %%.....???????????check/////
% roll_max = 147;
% pitch_max = 147;
% yaw_rate_max = 147;
% throttle_min = -147; %%.....???????????check/////
% roll_min = -147;
% pitch_min = -147;
% yaw_rate_min = -147;

% trim limits as set in the transmitter
handles.trim_lim = [43; 43; 43; 43];
% trim_throttle_max = 43; %%.....???????????check/////
% trim_roll_max = 43;
% trim_pitch_max = 43;
% trim_yaw_rate_max = 43;
% NOTE: it is assumed that limits are symmetric about zero
% scaling trim values
trim_scaled = trim.*(handles.trim_lim./handles.stick_lim);

pause(2); % initially arduino gives high values to the channels
send_stick_cmd(u_stick_cmd,trim_scaled,handles.sTrainerBox);

%create polar plots
test_copy2(handles.axes5,handles.sTrainerBox);
test_copy(handles.axes4,handles.sTrainerBox);

% TODO
% create a display 

% Choose default command line output for panel_test
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);


%%
% UIWAIT makes panel_test wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = panel_test_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%% mycode
disp('executing outputfcn');
% clear panel_test_OpeningFcn;
% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
    % throttle trim
u_stick_cmd(1:4) = inf;
trim_scaled(2:4) = inf;
trim_scaled(1) = hObject.Value*handles.trim_lim(1)/handles.stick_lim(1);
send_stick_cmd(u_stick_cmd,trim_scaled,handles.sTrainerBox);


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
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
%yaw slider
u_stick_cmd(1:4) = inf;
trim_scaled(1:3) = inf;
trim_scaled(4) = hObject.Value*handles.trim_lim(4)/handles.stick_lim(4);
send_stick_cmd(u_stick_cmd,trim_scaled,handles.sTrainerBox);


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
% hObject    handle to axes4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes4
% handles
% test_copy(hObject,handles.sTrainerBox);


% --- Executes during object creation, after setting all properties.
function axes5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes5

% test_copy2(hObject);


% --- Executes on slider movement.
function slider5_Callback(hObject, eventdata, handles)
% pitch slider
u_stick_cmd(1:4) = inf;
trim_scaled(1:4) = inf;
trim_scaled(3) = hObject.Value*handles.trim_lim(3)/handles.stick_lim(3);
send_stick_cmd(u_stick_cmd,trim_scaled,handles.sTrainerBox);

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
% roll slider
u_stick_cmd(1:4) = inf;
trim_scaled(1:4) = inf;
trim_scaled(2) = hObject.Value*handles.trim_lim(2)/handles.stick_lim(2);
send_stick_cmd(u_stick_cmd,trim_scaled,handles.sTrainerBox);



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
% display a question dialog box 
%    selection = questdlg('exit?',...
%       'Close Request Function',...
%       'Yes','No','Yes'); 
%    switch selection, 
%       case 'Yes'     
%       case 'No'
%       return 
%    end    
% save trim values to file 
% save throttle trim to zero always
 trim = [0; handles.slider6.Value;...
         handles.slider5.Value; handles.slider3.Value];
 fname = 'trim.txt';
 fid = fopen(fname,'w');
 dlmwrite(fname,trim);
 fclose(fid);
 % close com port
% fclose(handles.sTrainerBox);
% throws an error sometimes
 disp('BYE');  
 delete(hObject);
