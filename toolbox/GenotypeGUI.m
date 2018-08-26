function varargout = GenotypeGUI(varargin)
% GENOTYPEGUI MATLAB code for GenotypeGUI.fig
%      GENOTYPEGUI, by itself, creates a new GENOTYPEGUI or raises the existing
%      singleton*.
%
%      H = GENOTYPEGUI returns the handle to a new GENOTYPEGUI or the handle to
%      the existing singleton*.
%
%      GENOTYPEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GENOTYPEGUI.M with the given input arguments.
%
%      GENOTYPEGUI('Property','Value',...) creates a new GENOTYPEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GenotypeGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GenotypeGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GenotypeGUI

% Last Modified by GUIDE v2.5 03-Apr-2012 13:54:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GenotypeGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GenotypeGUI_OutputFcn, ...
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


% --- Executes just before GenotypeGUI is made visible.
function GenotypeGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GenotypeGUI (see VARARGIN)

% --- GUI organisation:
% Collect mainScreen handle to use for passing data between GUI's.
[~,figure] = gcbo;
handles.mainScreen = figure;
if(ishandle(figure))
    data = get(handles.mainScreen,'UserData');
    if(isempty(data{1}))
        set(handles.genotypeBox,'String','{[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]}');
    else
        set(handles.genotypeBox,'String',data{1});
    end
else
    error('Genotype Screen was not called from Main Screen');
end
% Choose default command line output for GenotypeGUI
handles.output = hObject;
% Add handles.changes to handles structure (to record node changes):
handles.changes = cell(1);
% Update handles structure
guidata(hObject, handles);
% Centre GUI in screen:
movegui(handles.genotypeScreen,'center');

% -- Box updates:
% Set selectNodeBox to correct values
temp1 = get(handles.genotypeBox,'String');
[~,noOfGenes] = size(regexp(temp1,'\]'));
cellS = cell(1,1);
for i=1:noOfGenes
    cellS{i} = num2str(i);
end
set(handles.selectNodeBox,'Value',1);
set(handles.selectNodeBox,'String',char(cellS));
selectNodeBox_Callback(handles.selectNodeBox, [], handles);

% -- Layout Screen updates:
data = get(handles.mainScreen,'UserData');
cla(handles.axes1);
axes(handles.axes1);
eval(['updateLayoutDisplay(',strtrim(get(handles.genotypeBox,'String')),...
                                              ',',strtrim(data{2}),');']);

% UIWAIT makes GenotypeGUI wait for user response (see UIRESUME)
% uiwait(handles.genotypeScreen);


% --- Outputs from this function are returned to the command line.
function varargout = GenotypeGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in genotypeBox.
function genotypeBox_Callback(hObject, eventdata, handles)
% hObject    handle to genotypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns genotypeBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from genotypeBox


% --- Executes during object creation, after setting all properties.
function genotypeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genotypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in backKeepButton.
function backKeepButton_Callback(hObject, eventdata, handles)
% hObject    handle to backKeepButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.mainScreen,'UserData');
newData{1} = get(handles.genotypeBox,'String');
newData{2} = data{2};
newData{3} = handles.changes;
set(handles.mainScreen,'UserData',newData);
set(handles.mainScreen,'Visible','on');
delete(handles.genotypeScreen);


% --- Executes on button press in backForgetButton.
function backForgetButton_Callback(hObject, eventdata, handles)
% hObject    handle to backForgetButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data = get(handles.mainScreen,'UserData');
newData{1} = data{1};
newData{2} = data{2};
newData{3} = [];
set(handles.mainScreen,'UserData',newData);
set(handles.mainScreen,'Visible','on');
delete(handles.genotypeScreen);


% --- Executes on button press in addNodeButton.
function addNodeButton_Callback(hObject, eventdata, handles)
% hObject    handle to addNodeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp1 = get(handles.genotypeBox,'String');
[~,noOfGenes] = size(regexp(temp1,'\]'));
node = (get(handles.selectNodeBox,'Value'));

nodeVals(1) = get(handles.xPosBox,'String');
if(str2double(char(nodeVals(1)))<0 ||...
        str2double(char(nodeVals(1)))>99 || isempty(char(nodeVals(1))))
    error('Incorrect xPos value: must be 0-99');
end
nodeVals(2) = get(handles.yPosBox,'String');
if(str2double(char(nodeVals(2)))<0 ||...
        str2double(char(nodeVals(2)))>99 || isempty(char(nodeVals(2))))
    error('Incorrect yPos value: must be 0-99');
end
nodeVals(3) = get(handles.pRadBox,'String');
if(str2double(char(nodeVals(3)))<0 ||...
        str2double(char(nodeVals(3)))>99 || isempty(char(nodeVals(3))))
    error('Incorrect positive radius value: must be 0-99');
end
nodeVals(4) = get(handles.pTheta1Box,'String');
if(str2double(char(nodeVals(4)))<0 ||...
        str2double(char(nodeVals(4)))>99 || isempty(char(nodeVals(4))))
    error('Incorrect positive theta1 value: must be 0-99');
end
nodeVals(5) = get(handles.pTheta2Box,'String');
if(str2double(char(nodeVals(5)))<0 ||...
        str2double(char(nodeVals(5)))>99 || isempty(char(nodeVals(5))))
    error('Incorrect positive theta2 value: must be 0-99');
end
nodeVals(6) = get(handles.nRadBox,'String');
if(str2double(char(nodeVals(6)))<0 ||...
        str2double(char(nodeVals(6)))>99 || isempty(char(nodeVals(6))))
    error('Incorrect negative radius value: must be 0-99');
end
nodeVals(7) = get(handles.nTheta1Box,'String');
if(str2double(char(nodeVals(7)))<0 ||...
        str2double(char(nodeVals(7)))>99 || isempty(char(nodeVals(7))))
    error('Incorrect negative theta1 value: must be 0-99');
end
nodeVals(8) = get(handles.nTheta2Box,'String');
if(str2double(char(nodeVals(8)))<0 ||...
        str2double(char(nodeVals(8)))>99 || isempty(char(nodeVals(8))))
    error('Incorrect negative theta2 value: must be 0-99');
end
test1 = double(get(handles.recurBox,'Value'));
if(test1 == 1), nodeVals{9} = '0';
elseif(test1 == 2), nodeVals{9} = '1';
elseif(test1 == 3), nodeVals{9} = '2';
end
test2 = get(handles.emissTypeBox,'Value');
if(test2 == 1), nodeVals{10} = '0';
elseif(test2 == 2), nodeVals{10} = '1';
elseif(test2 == 3), nodeVals{10} = '2';
elseif(test2 == 4), nodeVals{10} = '3';
end
test3 = get(handles.gasTypeBox,'Value');
if(test3 == 1), nodeVals{11} = '0';
elseif(test3 == 2), nodeVals{11} = '1';
end
nodeVals(12) = get(handles.gasDecayBox,'String');
if(str2double(char(nodeVals(12)))<0 ||...
        str2double(char(nodeVals(12)))>99 || isempty(char(nodeVals(12))))
    error('Incorrect gas decay value: must be 0-99');
end
nodeVals(13) = get(handles.gasRadBox,'String');
if(str2double(char(nodeVals(13)))<0 ||...
        str2double(char(nodeVals(13)))>99 || isempty(char(nodeVals(13))))
    error('Incorrect gas radius value: must be 0-99');
end
nodeVals(14) = get(handles.biasBox,'String');
if(str2double(char(nodeVals(14)))<0 ||...
        str2double(char(nodeVals(14)))>99 || isempty(char(nodeVals(14))))
    error('Incorrect bias value: must be 0-99');
end
nodeVals(15) = get(handles.tanhBox,'String');
if(str2double(char(nodeVals(15)))<0 ||...
        str2double(char(nodeVals(15)))>99 || isempty(char(nodeVals(15))))
    error('Incorrect tanh value: must be 0-99');
end
test4 = get(handles.isInputBox,'Value');
if(test4 == 1), nodeVals{16} = '0';
elseif(test4 == 2), nodeVals{16} = '1';
end

gene = ['[',nodeVals{1},',',nodeVals{2},',',nodeVals{3},',',...
    nodeVals{4},',',nodeVals{5},',',nodeVals{6},',',nodeVals{7},',',...
    nodeVals{8},',',nodeVals{9},',',nodeVals{10},',',nodeVals{11},',',...
    nodeVals{12},',',nodeVals{13},',',nodeVals{14},',',nodeVals{15},',',...
    nodeVals{16},']'];

matches = regexp(temp1,'\[[^\]]*\]','match');
matches{noOfGenes+1} = gene;
newGenotype = '{';
for i=1:noOfGenes+1
    if(i<noOfGenes+1)
        newGenotype = [newGenotype,matches{i},','];
    else
        newGenotype = [newGenotype,matches{i}];
    end
end
newGenotype = [newGenotype,'}'];
    
% -- Box updates:
% Update genotype box:
set(handles.genotypeBox,'String',newGenotype);
% Update select genotype box:
cellS = cell(1,1);
for i=1:noOfGenes+1
    cellS{i} = num2str(i);
end
set(handles.selectNodeBox,'Value',1);
set(handles.selectNodeBox,'String',char(cellS));
selectNodeBox_Callback(handles.selectNodeBox, [], handles);
% Update handles.changes to include node change:
if(isempty(find(cell2mat(handles.changes),node)))
    [~,length] = size(handles.changes);
    handles.changes{length+1} = node;
end

% -- Layout display updates:
data = get(handles.mainScreen,'UserData');
cla(handles.axes1);
eval(['updateLayoutDisplay(',strtrim(get(handles.genotypeBox,'String')),...
                                              ',',strtrim(data{2}),');']);


% --- Executes on button press in moveNodeButton.
function moveNodeButton_Callback(hObject, eventdata, handles)
% hObject    handle to moveNodeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp1 = get(handles.genotypeBox,'String');
[~,noOfGenes] = size(regexp(temp1,'\]'));
matches = regexp(temp1,'\[[^\]]*\]','match');

% Convert to genotype value:
[x,y] = ginput(1);
gX = x*99;
gY = y*99;
if(gX<0||gX>99||gY<0||gY>99)
    error('Ensure clicked point is between 0-99.');
end

distances = zeros(noOfGenes,2);
for i=1:noOfGenes
    vals = regexp(matches{i},'[\d]*','match');
    distances(i,1) = i;
    x1 = str2double(vals{1});
    y1 = str2double(vals{2});
    x2 = ceil(gX);
    y2 = ceil(gY);
    distances(i,2) = sqrt(((x2-x1)^2)+(((y2-y1)^2)));
end
distances = sortrows(distances,2);
node = distances(1,1);

k = strfind(matches(node),',');
[~,c] = size(matches{node});
newGene = ['[',num2str(ceil(gX)),',',num2str(ceil(gY))];
newGene = [newGene,matches{node}(k{1}(2):c)];
matches{node} = newGene;
newGenotype = '{';
for i=1:noOfGenes
    if(i<noOfGenes)
        newGenotype = [newGenotype,matches{i},','];
    else
        newGenotype = [newGenotype,matches{i}];
    end
end
newGenotype = [newGenotype,'}'];

% -- Box updates:
% Update genotype box:
set(handles.genotypeBox,'String',newGenotype);
% Update handles.changes to include node change:
if(isempty(find(cell2mat(handles.changes),node)))
    [~,length] = size(handles.changes);
    handles.changes{length+1} = node;
end
% Reset select node box:
set(handles.selectNodeBox,'Value',node);
selectNodeBox_Callback(handles.selectNodeBox, [], handles);
% -- Layout display updates:
data = get(handles.mainScreen,'UserData');
cla(handles.axes1);
eval(['updateLayoutDisplay(',strtrim(get(handles.genotypeBox,'String')),...
                                              ',',strtrim(data{2}),');']);
                                          
% --- Executes on selection change in selectNodeBox.
function selectNodeBox_Callback(hObject, eventdata, handles)
% hObject    handle to selectNodeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectNodeBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectNodeBox
data = get(handles.mainScreen,'UserData');
nomChars = regexp(strtrim(data{2}),'[\d]+','match');

temp1 = get(handles.genotypeBox,'String');
[~,noOfGenes] = size(regexp(temp1,'\]'));
numbers = regexp(temp1,'\D+','split');
[~,max]=size(numbers);
numbers = numbers(2:max-1);
node = (get(hObject,'Value'));
if(node == 1)
    startpoint = 1;
    endpoint = startpoint+15;
else
    startpoint = ((node-1)*16)+1;
    endpoint = startpoint+15;
end
nodeVals = numbers(startpoint:endpoint);

set(handles.xPosBox,'String',nodeVals(1));
set(handles.yPosBox,'String',nodeVals(2));
set(handles.pRadBox,'String',nodeVals(3));
set(handles.pTheta1Box,'String',nodeVals(4));
set(handles.pTheta2Box,'String',nodeVals(5));
set(handles.nRadBox,'String',nodeVals(6));
set(handles.nTheta1Box,'String',nodeVals(7));
set(handles.nTheta2Box,'String',nodeVals(8));
test1 = char(nodeVals(9));
if(mod(str2double(test1),str2double(nomChars{9}))==0)
    set(handles.recurBox,'Value',1);
elseif(mod(str2double(test1),str2double(nomChars{9}))==1)
    set(handles.recurBox,'Value',2);
elseif(mod(str2double(test1),str2double(nomChars{9}))==2)
    set(handles.recurBox,'Value',3);
end
test2 = char(nodeVals(10));
if(mod(str2double(test2),str2double(nomChars{10}))==0)
    set(handles.emissTypeBox,'Value',1);
elseif(mod(str2double(test2),str2double(nomChars{10}))==1)
    set(handles.emissTypeBox,'Value',2);
elseif(mod(str2double(test2),str2double(nomChars{10}))==2)
    set(handles.emissTypeBox,'Value',3);
elseif(mod(str2double(test2),str2double(nomChars{10}))==3)
    set(handles.emissTypeBox,'Value',4);
end
test3 = char(nodeVals(11));
if(mod(str2double(test3),str2double(nomChars{10}))==0)
    set(handles.gasTypeBox,'Value',1);
elseif(mod(str2double(test3),str2double(nomChars{10}))==1)
    set(handles.gasTypeBox,'Value',2);
end
set(handles.gasDecayBox,'String',nodeVals(12));
set(handles.gasRadBox,'String',nodeVals(13));
set(handles.biasBox,'String',nodeVals(14));
set(handles.tanhBox,'String',nodeVals(15));
test4 = char(nodeVals(16));
if(mod(str2double(test4),str2double(nomChars{10}))==0)
    set(handles.isInputBox,'Value',1);
elseif(mod(str2double(test4),str2double(nomChars{10}))==1)
    set(handles.isInputBox,'Value',2);
end

% --- Executes during object creation, after setting all properties.
function selectNodeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectNodeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function yPosBox_Callback(hObject, eventdata, handles)
% hObject    handle to yPosBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of yPosBox as text
%        str2double(get(hObject,'String')) returns contents of yPosBox as a double


% --- Executes during object creation, after setting all properties.
function yPosBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to yPosBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function xPosBox_Callback(hObject, eventdata, handles)
% hObject    handle to xPosBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of xPosBox as text
%        str2double(get(hObject,'String')) returns contents of xPosBox as a double


% --- Executes during object creation, after setting all properties.
function xPosBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xPosBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pTheta1Box_Callback(hObject, eventdata, handles)
% hObject    handle to pTheta1Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pTheta1Box as text
%        str2double(get(hObject,'String')) returns contents of pTheta1Box as a double


% --- Executes during object creation, after setting all properties.
function pTheta1Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pTheta1Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pRadBox_Callback(hObject, eventdata, handles)
% hObject    handle to pRadBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pRadBox as text
%        str2double(get(hObject,'String')) returns contents of pRadBox as a double


% --- Executes during object creation, after setting all properties.
function pRadBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pRadBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function pTheta2Box_Callback(hObject, eventdata, handles)
% hObject    handle to pTheta2Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of pTheta2Box as text
%        str2double(get(hObject,'String')) returns contents of pTheta2Box as a double


% --- Executes during object creation, after setting all properties.
function pTheta2Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pTheta2Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nTheta1Box_Callback(hObject, eventdata, handles)
% hObject    handle to nTheta1Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nTheta1Box as text
%        str2double(get(hObject,'String')) returns contents of nTheta1Box as a double


% --- Executes during object creation, after setting all properties.
function nTheta1Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nTheta1Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nRadBox_Callback(hObject, eventdata, handles)
% hObject    handle to nRadBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nRadBox as text
%        str2double(get(hObject,'String')) returns contents of nRadBox as a double


% --- Executes during object creation, after setting all properties.
function nRadBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nRadBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nTheta2Box_Callback(hObject, eventdata, handles)
% hObject    handle to nTheta2Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nTheta2Box as text
%        str2double(get(hObject,'String')) returns contents of nTheta2Box as a double


% --- Executes during object creation, after setting all properties.
function nTheta2Box_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nTheta2Box (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in recurBox.
function recurBox_Callback(hObject, eventdata, handles)
% hObject    handle to recurBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns recurBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from recurBox


% --- Executes during object creation, after setting all properties.
function recurBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recurBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in emissTypeBox.
function emissTypeBox_Callback(hObject, eventdata, handles)
% hObject    handle to emissTypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns emissTypeBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from emissTypeBox


% --- Executes during object creation, after setting all properties.
function emissTypeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to emissTypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gasTypeBox_Callback(hObject, eventdata, handles)
% hObject    handle to gasTypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gasTypeBox as text
%        str2double(get(hObject,'String')) returns contents of gasTypeBox as a double


% --- Executes during object creation, after setting all properties.
function gasTypeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gasTypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gasRadBox_Callback(hObject, eventdata, handles)
% hObject    handle to gasRadBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gasRadBox as text
%        str2double(get(hObject,'String')) returns contents of gasRadBox as a double


% --- Executes during object creation, after setting all properties.
function gasRadBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gasRadBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tanhBox_Callback(hObject, eventdata, handles)
% hObject    handle to tanhBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tanhBox as text
%        str2double(get(hObject,'String')) returns contents of tanhBox as a double


% --- Executes during object creation, after setting all properties.
function tanhBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tanhBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function biasBox_Callback(hObject, eventdata, handles)
% hObject    handle to biasBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of biasBox as text
%        str2double(get(hObject,'String')) returns contents of biasBox as a double


% --- Executes during object creation, after setting all properties.
function biasBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to biasBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in isInputBox.
function isInputBox_Callback(hObject, eventdata, handles)
% hObject    handle to isInputBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns isInputBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from isInputBox


% --- Executes during object creation, after setting all properties.
function isInputBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to isInputBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in saveNodeChangesButton.
function saveNodeChangesButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveNodeChangesButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp1 = get(handles.genotypeBox,'String');
[~,noOfGenes] = size(regexp(temp1,'\]'));
node = (get(handles.selectNodeBox,'Value'));

nodeVals(1) = get(handles.xPosBox,'String');
if(str2double(char(nodeVals(1)))<0 ||...
        str2double(char(nodeVals(1)))>99 || isempty(char(nodeVals(1))))
    error('Incorrect xPos value: must be 0-99');
end
nodeVals(2) = get(handles.yPosBox,'String');
if(str2double(char(nodeVals(2)))<0 ||...
        str2double(char(nodeVals(2)))>99 || isempty(char(nodeVals(2))))
    error('Incorrect yPos value: must be 0-99');
end
nodeVals(3) = get(handles.pRadBox,'String');
if(str2double(char(nodeVals(3)))<0 ||...
        str2double(char(nodeVals(3)))>99 || isempty(char(nodeVals(3))))
    error('Incorrect positive radius value: must be 0-99');
end
nodeVals(4) = get(handles.pTheta1Box,'String');
if(str2double(char(nodeVals(4)))<0 ||...
        str2double(char(nodeVals(4)))>99 || isempty(char(nodeVals(4))))
    error('Incorrect positive theta1 value: must be 0-99');
end
nodeVals(5) = get(handles.pTheta2Box,'String');
if(str2double(char(nodeVals(5)))<0 ||...
        str2double(char(nodeVals(5)))>99 || isempty(char(nodeVals(5))))
    error('Incorrect positive theta2 value: must be 0-99');
end
nodeVals(6) = get(handles.nRadBox,'String');
if(str2double(char(nodeVals(6)))<0 ||...
        str2double(char(nodeVals(6)))>99 || isempty(char(nodeVals(6))))
    error('Incorrect negative radius value: must be 0-99');
end
nodeVals(7) = get(handles.nTheta1Box,'String');
if(str2double(char(nodeVals(7)))<0 ||...
        str2double(char(nodeVals(7)))>99 || isempty(char(nodeVals(7))))
    error('Incorrect negative theta1 value: must be 0-99');
end
nodeVals(8) = get(handles.nTheta2Box,'String');
if(str2double(char(nodeVals(8)))<0 ||...
        str2double(char(nodeVals(8)))>99 || isempty(char(nodeVals(8))))
    error('Incorrect negative theta2 value: must be 0-99');
end
test1 = double(get(handles.recurBox,'Value'));
if(test1 == 1), nodeVals{9} = '0';
elseif(test1 == 2), nodeVals{9} = '1';
elseif(test1 == 3), nodeVals{9} = '2';
end
test2 = get(handles.emissTypeBox,'Value');
if(test2 == 1), nodeVals{10} = '0';
elseif(test2 == 2), nodeVals{10} = '1';
elseif(test2 == 3), nodeVals{10} = '2';
elseif(test2 == 4), nodeVals{10} = '3';
end
test3 = get(handles.gasTypeBox,'Value');
if(test3 == 1), nodeVals{11} = '0';
elseif(test3 == 2), nodeVals{11} = '1';
end
nodeVals(12) = get(handles.gasDecayBox,'String');
if(str2double(char(nodeVals(12)))<0 ||...
        str2double(char(nodeVals(12)))>99 || isempty(char(nodeVals(12))))
    error('Incorrect gas decay value: must be 0-99');
end
nodeVals(13) = get(handles.gasRadBox,'String');
if(str2double(char(nodeVals(13)))<0 ||...
        str2double(char(nodeVals(13)))>99 || isempty(char(nodeVals(13))))
    error('Incorrect gas radius value: must be 0-99');
end
nodeVals(14) = get(handles.biasBox,'String');
if(str2double(char(nodeVals(14)))<0 ||...
        str2double(char(nodeVals(14)))>99 || isempty(char(nodeVals(14))))
    error('Incorrect bias value: must be 0-99');
end
nodeVals(15) = get(handles.tanhBox,'String');
if(str2double(char(nodeVals(15)))<0 ||...
        str2double(char(nodeVals(15)))>99 || isempty(char(nodeVals(15))))
    error('Incorrect tanh value: must be 0-99');
end
test4 = get(handles.isInputBox,'Value');
if(test4 == 1), nodeVals{16} = '0';
elseif(test4 == 2), nodeVals{16} = '1';
end

gene = ['[',nodeVals{1},',',nodeVals{2},',',nodeVals{3},',',...
    nodeVals{4},',',nodeVals{5},',',nodeVals{6},',',nodeVals{7},',',...
    nodeVals{8},',',nodeVals{9},',',nodeVals{10},',',nodeVals{11},',',...
    nodeVals{12},',',nodeVals{13},',',nodeVals{14},',',nodeVals{15},',',...
    nodeVals{16},']'];


matches = regexp(temp1,'\[[^\]]*\]','match');
matches{node} = gene;
newGenotype = '{';
for i=1:noOfGenes
    if(i<noOfGenes)
        newGenotype = [newGenotype,matches{i},','];
    else
        newGenotype = [newGenotype,matches{i}];
    end
end
newGenotype = [newGenotype,'}'];
    
% -- Box updates:
% Update genotype box:
set(handles.genotypeBox,'String',newGenotype);
% Update handles.changes to include node change:
if(isempty(find(cell2mat(handles.changes),node)))
    [~,length] = size(handles.changes);
    handles.changes{length+1} = node;
end

% -- Layout display updates:
data = get(handles.mainScreen,'UserData');
cla(handles.axes1);
axes(handles.axes1);
eval(['updateLayoutDisplay(',strtrim(get(handles.genotypeBox,'String')),...
                                              ',',strtrim(data{2}),');']);


% --- Executes on button press in removeNodeButton.
function removeNodeButton_Callback(hObject, eventdata, handles)
% hObject    handle to removeNodeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
temp1 = get(handles.genotypeBox,'String');
[~,noOfGenes] = size(regexp(temp1,'\]'));
if(noOfGenes<2)
    error('There must be at least one node.');
end
node = (get(handles.selectNodeBox,'Value'));

matches = regexp(temp1,'\[[^\]]*\]','match');
newGenotype = '{';
for i=1:noOfGenes
    if(i==node), continue;
    elseif(i<noOfGenes), newGenotype = [newGenotype,matches{i},','];
    else newGenotype = [newGenotype,matches{i}];
    end
end
newGenotype = [newGenotype,'}'];
    
% -- Box updates:
% Update genotype box:
set(handles.genotypeBox,'String',newGenotype);
% Update select genotype box:
cellS = cell(1,1);
for i=1:noOfGenes-1
    cellS{i} = num2str(i);
end
set(handles.selectNodeBox,'Value',1);
set(handles.selectNodeBox,'String',char(cellS));
selectNodeBox_Callback(handles.selectNodeBox, [], handles);
% Update handles.changes to include node change:
if(isempty(find(cell2mat(handles.changes),node)))
    [~,length] = size(handles.changes);
    handles.changes{length+1} = node;
end

% -- Layout display updates:
data = get(handles.mainScreen,'UserData');
cla(handles.axes1);
axes(handles.axes1);
eval(['updateLayoutDisplay(',strtrim(get(handles.genotypeBox,'String')),...
                                              ',',strtrim(data{2}),');']);


function gasDecayBox_Callback(hObject, eventdata, handles)
% hObject    handle to gasDecayBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gasDecayBox as text
%        str2double(get(hObject,'String')) returns contents of gasDecayBox as a double


% --- Executes during object creation, after setting all properties.
function gasDecayBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gasDecayBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
