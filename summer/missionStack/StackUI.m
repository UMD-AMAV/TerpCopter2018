function varargout = StackUI(varargin)
% STACKUI MATLAB code for StackUI.fig
%      STACKUI, by itself, creates a new STACKUI or raises the existing
%      singleton*.
%
%      H = STACKUI returns the handle to a new STACKUI or the handle to
%      the existing singleton*.
%
%      STACKUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in STACKUI.M with the given input arguments.
%
%      STACKUI('Property','Value',...) creates a new STACKUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before StackUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to StackUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help StackUI


% Last Modified by GUIDE v2.5 28-Jun-2018 18:20:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @StackUI_OpeningFcn, ...
                   'gui_OutputFcn',  @StackUI_OutputFcn, ...
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


% --- Executes just before StackUI is made visible.
function StackUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to StackUI (see VARARGIN)

% Choose default command line output for StackUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

clc;

% UIWAIT makes StackUI wait for user response (see UIRESUME)
% uiwait(handles.StackUI);


% --- Outputs from this function are returned to the command line.
function varargout = StackUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in CreateNewMissionButton.
function CreateNewMissionButton_Callback(hObject, eventdata, handles)
% hObject    handle to CreateNewMissionButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
currentMissionList = get(handles.CurrentMissionPopUp, 'String')     % Gets the Mission Pop Up (Should start empty and update when missions are added)
[numRow numCol] = size(currentMissionList);                         
new_mission = get(handles.MissionNameEdit, 'String');               % Gets the Mission Name from text edit box
newMissionString{1} = new_mission
missionStackCellArray = {0}

missionStackTable = get(handles.StackTable, 'Data');

if isempty(currentMissionList) == 1
    temp = get(handles.CurrentMissionPopUp, 'String');              % Makes a Cell Array for Mission Names
    temp{end + 1} = new_mission;                                    % Places the Mission Name from text edit box to the end of the Cell Array
    set(handles.CurrentMissionPopUp, 'String', temp);

    set(handles.StackTable, 'ColumnName', new_mission);
    setappdata(handles.CreateNewMissionButton, 'missionStackCellArray', missionStackCellArray)

    set(handles.StackTable, 'ColumnWidth',  {825})
else
    check = strcmp( currentMissionList, new_mission)
    
    repeat = 0
    for missionCounter = 1:numRow
        if check(missionCounter) == 1
            repeat = 1
            break
        end
    end
    
    if repeat == 0
        missionNumber = numRow + 1
        temp = get(handles.CurrentMissionPopUp, 'String');      % Makes a Cell Array for Mission Names
        temp{end + 1} = new_mission;                            % Places the Mission Name from text edit box to the end of the Cell Array
        set(handles.CurrentMissionPopUp, 'String', temp);       % Sets the created Cell Array as the updated Pop Up Menu
    
        set(handles.StackTable, 'ColumnName', temp)
        missionStackTable{:,end+1} = 0
    end
    set(handles.StackTable, 'Data', missionStackTable)
    setappdata(handles.CreateNewMissionButton, 'missionStackCellArray', missionStackTable)
    
    set(handles.StackTable, 'ColumnWidth',  {825/(numRow + 1)})
end


function MissionNameEdit_Callback(hObject, eventdata, handles)
% hObject    handle to MissionNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MissionNameEdit as text
%        str2double(get(hObject,'String')) returns contents of MissionNameEdit as a double

input = get(hObject,'String')  %Gets the Mission Name input as a string


% --- Executes during object creation, after setting all properties.
function MissionNameEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MissionNameEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CurrentMissionPopUp.
function CurrentMissionPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentMissionPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CurrentMissionPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CurrentMissionPopUp
mission = get(hObject, 'String')
state = get(hObject, 'Value')



% --- Executes during object creation, after setting all properties.
function CurrentMissionPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentMissionPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function NewBehaviorEdit_Callback(hObject, eventdata, handles)
% hObject    handle to NewBehaviorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NewBehaviorEdit as text
%        str2double(get(hObject,'String')) returns contents of NewBehaviorEdit as a double


% --- Executes during object creation, after setting all properties.
function NewBehaviorEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NewBehaviorEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in CurrentlySelectedBehaviorPopUp.
function CurrentlySelectedBehaviorPopUp_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentlySelectedBehaviorPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns CurrentlySelectedBehaviorPopUp contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CurrentlySelectedBehaviorPopUp
behaviorName = get(hObject, 'String')
state = get(hObject, 'Value')

% --- Executes during object creation, after setting all properties.
function CurrentlySelectedBehaviorPopUp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentlySelectedBehaviorPopUp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CreateNewBehaviorButton.
function CreateNewBehaviorButton_Callback(hObject, eventdata, handles)
% hObject    handle to CreateNewBehaviorButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
new_behavior = get(handles.NewBehaviorEdit, 'String');
temp = get(handles.CurrentlySelectedBehaviorPopUp, 'String');
temp{end + 1} = new_behavior;
set(handles.CurrentlySelectedBehaviorPopUp, 'String', temp);


function KheightEdit_Callback(hObject, eventdata, handles)
% hObject    handle to KheightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of KheightEdit as text
%        str2double(get(hObject,'String')) returns contents of KheightEdit as a double
input = str2num(get(hObject, 'String'))

% --- Executes during object creation, after setting all properties.
function KheightEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KheightEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function heightdesiredEdit_Callback(hObject, eventdata, handles)
% hObject    handle to heightdesiredEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of heightdesiredEdit as text
%        str2double(get(hObject,'String')) returns contents of heightdesiredEdit as a double
input = str2num(get(hObject, 'String'))

% --- Executes during object creation, after setting all properties.
function heightdesiredEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to heightdesiredEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function KyawEdit_Callback(hObject, eventdata, handles)
% hObject    handle to KyawEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of KyawEdit as text
%        str2double(get(hObject,'String')) returns contents of KyawEdit as a double
input = str2num(get(hObject, 'String'))

% --- Executes during object creation, after setting all properties.
function KyawEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KyawEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function yawdesiredEdit_Callback(hObject, eventdata, handles)
% hObject    handle to yawdesiredEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yawdesiredEdit as text
%        str2double(get(hObject,'String')) returns contents of yawdesiredEdit as a double
input = str2num(get(hObject, 'String'))

% --- Executes during object creation, after setting all properties.
function yawdesiredEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yawdesiredEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function KforwardEdit_Callback(hObject, eventdata, handles)
% hObject    handle to KforwardEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of KforwardEdit as text
%        str2double(get(hObject,'String')) returns contents of KforwardEdit as a double
input = str2num(get(hObject, 'String'))


% --- Executes during object creation, after setting all properties.
function KforwardEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KforwardEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function forwarddesiredEdit_Callback(hObject, eventdata, handles)
% hObject    handle to forwarddesiredEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of forwarddesiredEdit as text
%        str2double(get(hObject,'String')) returns contents of forwarddesiredEdit as a double
input = str2num(get(hObject, 'String'))


% --- Executes during object creation, after setting all properties.
function forwarddesiredEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forwarddesiredEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function KsideEdit_Callback(hObject, eventdata, handles)
% hObject    handle to KsideEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of KsideEdit as text
%        str2double(get(hObject,'String')) returns contents of KsideEdit as a double
input = str2num(get(hObject, 'String'))


% --- Executes during object creation, after setting all properties.
function KsideEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to KsideEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function sidedesiredEdit_Callback(hObject, eventdata, handles)
% hObject    handle to sidedesiredEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sidedesiredEdit as text
%        str2double(get(hObject,'String')) returns contents of sidedesiredEdit as a double
input = str2num(get(hObject, 'String'))


% --- Executes during object creation, after setting all properties.
function sidedesiredEdit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sidedesiredEdit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushButton.
function pushButton_Callback(hObject, eventdata, handles)
% hObject    handle to pushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
behaviorNameList = get(handles.CurrentlySelectedBehaviorPopUp, 'String');
behaviorState = get(handles.CurrentlySelectedBehaviorPopUp, 'Value');
missionStackTable = get(handles.StackTable, 'Data');
missionState = get(handles.CurrentMissionPopUp, 'Value');
missionStackCellArray = getappdata(handles.CreateNewMissionButton, 'missionStackCellArray')
behaviorName = behaviorNameList{behaviorState};
[numRow numCol] = size(missionStackCellArray)

K_h = str2num(get(handles.KheightEdit, 'String'));
h_d = str2num(get(handles.heightdesiredEdit, 'String'));

K_yaw = str2num(get(handles.KyawEdit, 'String'));
yaw_d = str2num(get(handles.yawdesiredEdit, 'String'));

K_u = str2num(get(handles.KforwardEdit, 'String'));
u_d = str2num(get(handles.forwarddesiredEdit, 'String'));

K_v = str2num(get(handles.KsideEdit, 'String'));
v_d = str2num(get(handles.sidedesiredEdit, 'String'));

% Places the Behavior Properties from GUI into the Behavior class
SelectedBehavior = behavior(behaviorName, K_h, h_d, K_yaw, yaw_d, K_u, u_d, K_v, v_d);

%Updates/Stores the Behavior Classes into the Mission Stack Cell Array 
missionStackCellArray = push(missionStackCellArray, missionState, numRow, SelectedBehavior)
setappdata(handles.CreateNewMissionButton, 'missionStackCellArray', missionStackCellArray);

%Updates/Stores the Behavior Name into the UITABLE in GUI
missionStackTable = push(missionStackTable, missionState, numRow, behaviorName);
set(handles.StackTable, 'Data', missionStackTable);

%%


% --- Executes on key press with focus on KheightEdit and none of its controls.
function KheightEdit_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to KheightEdit (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)

%keyPress = eventdata.Key

%switch keyPress
%    case 'downarrow'
%        heightdesiredEdit_Callback(handles.heightdersiredEdit, 'String', handles)
%end


% --- Executes when selected cell(s) is changed in StackTable.
function StackTable_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to StackTable (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
missionStackCellArray = getappdata(handles.CreateNewMissionButton, 'missionStackCellArray');

datatable_row = eventdata.Indices(1);
datatable_col = eventdata.Indices(2);

if isempty(missionStackCellArray)                                                                                            
else
    SelectedBehavior = missionStackCellArray{datatable_row, datatable_col}

    if SelectedBehavior == 0
    else
        K_h = SelectedBehavior.K_height;
        set(handles.KheightEdit, 'String', K_h);
        h_d = SelectedBehavior.height_d;
        set(handles.heightdesiredEdit, 'String', h_d);

        K_yaw = SelectedBehavior.K_yaw;
        set(handles.KyawEdit, 'String', K_yaw);
        yaw_d = SelectedBehavior.yaw_d;
        set(handles.yawdesiredEdit, 'String',yaw_d);

        K_u = SelectedBehavior.K_u;
        set(handles.KforwardEdit, 'String', K_u);
        u_d = SelectedBehavior.u_d;
        set(handles.forwarddesiredEdit, 'String', u_d);

        K_v = SelectedBehavior.K_v;
        set(handles.KsideEdit, 'String', K_v);
        v_d = SelectedBehavior.v_d;
        set(handles.sidedesiredEdit, 'String', v_d);
    end
end

clear datatable_col datatable_row




function CellBehaviorNameText_Callback(hObject, eventdata, handles)
% hObject    handle to CellBehaviorNameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CellBehaviorNameText as text
%        str2double(get(hObject,'String')) returns contents of CellBehaviorNameText as a double


% --- Executes during object creation, after setting all properties.
function CellBehaviorNameText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CellBehaviorNameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddButton.
function AddButton_Callback(hObject, eventdata, handles)
% hObject    handle to AddButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
behaviorNameList = get(handles.CurrentlySelectedBehaviorPopUp, 'String');
behaviorState = get(handles.CurrentlySelectedBehaviorPopUp, 'Value');
missionStackTable = get(handles.StackTable, 'Data');
missionState = get(handles.CurrentMissionPopUp, 'Value');
missionStackCellArray = getappdata(handles.CreateNewMissionButton, 'missionStackCellArray')
behaviorName = behaviorNameList{behaviorState};
[numRow numCol] = size(missionStackCellArray);

K_h = str2num(get(handles.KheightEdit, 'String'));
h_d = str2num(get(handles.heightdesiredEdit, 'String'));

K_yaw = str2num(get(handles.KyawEdit, 'String'));
yaw_d = str2num(get(handles.yawdesiredEdit, 'String'));

K_u = str2num(get(handles.KforwardEdit, 'String'));
u_d = str2num(get(handles.forwarddesiredEdit, 'String'));

K_v = str2num(get(handles.KsideEdit, 'String'));
v_d = str2num(get(handles.sidedesiredEdit, 'String'));

% Places the Behavior Properties from GUI into the Behavior class
SelectedBehavior = behavior(behaviorName, K_h, h_d, K_yaw, yaw_d, K_u, u_d, K_v, v_d);

%Updates/Stores the Behavior Classes into the Mission Stack Cell Array 
missionStackCellArray = add(missionStackCellArray, missionState, SelectedBehavior)
setappdata(handles.CreateNewMissionButton, 'missionStackCellArray', missionStackCellArray);

%Updates/Stores the Behavior Name into the UITABLE in GUI
missionStackTable = add(missionStackTable, missionState, behaviorName);
set(handles.StackTable, 'Data', missionStackTable);

setCel
