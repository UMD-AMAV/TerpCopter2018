function varargout = behaviorManager(varargin)
% BEHAVIORMANAGER MATLAB code for behaviorManager.fig
%      BEHAVIORMANAGER, by itself, creates a new BEHAVIORMANAGER or raises the existing
%      singleton*.
%
%      H = BEHAVIORMANAGER returns the handle to a new BEHAVIORMANAGER or the handle to
%      the existing singleton*.
%
%      BEHAVIORMANAGER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BEHAVIORMANAGER.M with the given input arguments.
%
%      BEHAVIORMANAGER('Property','Value',...) creates a new BEHAVIORMANAGER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before behaviorManager_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to behaviorManager_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help behaviorManager

% Last Modified by GUIDE v2.5 30-Jul-2018 16:04:16

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @behaviorManager_OpeningFcn, ...
                   'gui_OutputFcn',  @behaviorManager_OutputFcn, ...
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


% --- Executes just before behaviorManager is made visible.
function behaviorManager_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to behaviorManager (see VARARGIN)

global t_c_behavior_manager;
t_c_behavior_manager = timer('ExecutionMode','fixedRate','TimerFcn',{@behavior_manager,handles},'Period',0.1);
start(t_c_behavior_manager);

% Choose default command line output for behaviorManager
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes behaviorManager wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = behaviorManager_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Altitude_Callback(hObject, eventdata, handles)
% hObject    handle to Altitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Altitude as text
%        str2double(get(hObject,'String')) returns contents of Altitude as a double


% --- Executes during object creation, after setting all properties.
function Altitude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Altitude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
