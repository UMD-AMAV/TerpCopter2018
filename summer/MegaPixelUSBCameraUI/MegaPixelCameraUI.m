function varargout = MegaPixelCameraUI(varargin)
% MEGAPIXELCAMERAUI MATLAB code for MegaPixelCameraUI.fig
%      MEGAPIXELCAMERAUI, by itself, creates a new MEGAPIXELCAMERAUI or raises the existing
%      singleton*.
%
%      H = MEGAPIXELCAMERAUI returns the handle to a new MEGAPIXELCAMERAUI or the handle to
%      the existing singleton*.
%
%      MEGAPIXELCAMERAUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEGAPIXELCAMERAUI.M with the given input arguments.
%
%      MEGAPIXELCAMERAUI('Property','Value',...) creates a new MEGAPIXELCAMERAUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MegaPixelCameraUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MegaPixelCameraUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MegaPixelCameraUI

% Last Modified by GUIDE v2.5 29-Jun-2018 12:29:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MegaPixelCameraUI_OpeningFcn, ...
                   'gui_OutputFcn',  @MegaPixelCameraUI_OutputFcn, ...
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


% --- Executes just before MegaPixelCameraUI is made visible.
function MegaPixelCameraUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MegaPixelCameraUI (see VARARGIN)

% Choose default command line output for MegaPixelCameraUI
handles.output = hObject;

axes(handles.MegaPixelAxes);
vid = videoinput('winvideo',2);
hImage = image(zeros(1024,768,3), 'Parent', handles.MegaPixelAxes);
preview(vid, hImage);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MegaPixelCameraUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MegaPixelCameraUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
