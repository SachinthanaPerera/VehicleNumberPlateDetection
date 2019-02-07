function varargout = ok(varargin)
% OK MATLAB code for ok.fig
%      OK, by itself, creates a new OK or raises the existing
%      singleton*.
%
%      H = OK returns the handle to a new OK or the handle to
%      the existing singleton*.
%
%      OK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in OK.M with the given input arguments.
%
%      OK('Property','Value',...) creates a new OK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ok_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ok_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ok

% Last Modified by GUIDE v2.5 04-Jul-2018 21:55:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ok_OpeningFcn, ...
                   'gui_OutputFcn',  @ok_OutputFcn, ...
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


% --- Executes just before ok is made visible.
function ok_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ok (see VARARGIN)

% Choose default command line output for ok
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ok wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ok_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global s;
fn=uigetfile('*');% enables a user to select or enter the name of a file
s=imread(fn);
axes(handles.axes1);
imshow(s);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global s;
gray=rgb2gray(s);%convert rgb image to gray scale
sobe=edge(gray,'sobel',0.2);%detect edge(threshold)
se=strel('square',3);%create structural element
dil=imdilate(sobe,se);%dialate the image

fill=imfill(dil, 'holes');%Fill image regions and holes

dia=strel('square',1);
diamon=imerode(fill,dia);%do the erosion

li=strel('line',5,30);%length=5,degree=30
linee=imerode(diamon,li);

% removes all connected components (objects) that have fewer than P pixels
f=bwareaopen(linee,300);%pixel=300 

%get outermost boundaries of the objects
filledImage=imfill(f,'holes');

[labeledImage, numberOfObjects]=bwlabel(filledImage);
%Measure properties of image regions
measurements=regionprops(labeledImage,'Perimeter','FilledArea');

%store measurements into individual arrays
perimeters=[measurements.Perimeter];
filledAreas=[measurements.FilledArea];

%calculate circularities
circularities=perimeters.^2./(4*pi*filledAreas);

%print
fprintf('#,Perimeter,FilledArea,Circularity\n');
for Number = 1 : numberOfObjects
    fprintf('%d,%9.3f,%11.3f,%11.3f\n',Number,perimeters(Number),filledAreas(Number),circularities(Number));
end
axes(handles.axes2);
for Number = 1 : numberOfObjects
if (circularities(Number)>1.5 && circularities(Number)<4.0)

obj=(labeledImage==Number); 

[row,col] = find(obj);
length=max(row)-min(row)+2;
breadth=max(col)-min(col)+2;
target=uint8(zeros([length breadth]));
sy=min(col)-1;
sx=min(row)-1;

for i=1:size(row,1)
    x=row(i,1)-sx;
    y=col(i,1)-sy;
    target(x,y)=s(row(i,1),col(i,1));
end
imshow(target); 
end
end




