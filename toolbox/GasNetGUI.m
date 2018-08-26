function varargout = GasNetGUI(varargin)
% GASNETGUI MATLAB code for GasNetGUI.fig
%      GASNETGUI, by itself, creates a new GASNETGUI or raises the existing
%      singleton*.
%
%      H = GASNETGUI returns the handle to a new GASNETGUI or the handle to
%      the existing singleton*.
%
%      GASNETGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GASNETGUI.M with the given input arguments.
%
%      GASNETGUI('Property','Value',...) creates a new GASNETGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GasNetGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GasNetGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GasNetGUI

% Last Modified by GUIDE v2.5 10-Apr-2012 14:34:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GasNetGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GasNetGUI_OutputFcn, ...
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


% --- Executes just before GasNetGUI is made visible.
function GasNetGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GasNetGUI (see VARARGIN)

% Choose default command line output for GasNetGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Create GasNet-state fields in handles structure:
handles.outputState = [];
handles.emissState = [];
% Saving changes to handles structure:
guidata(hObject,handles);

% Centre GUI in screen:
movegui(handles.mainScreen,'center');

% UIWAIT makes GasNetGUI wait for user response (see UIRESUME)
% uiwait(handles.mainScreen);


% --- Outputs from this function are returned to the command line.
function varargout = GasNetGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function statusBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statusBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in runButton.
function runButton_Callback(hObject, eventdata, handles)
% hObject    handle to runButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cla(handles.axes1);
cla(handles.axes2);
set(handles.currentStepBox,'String','');
set(handles.status,'String','GasNet Running...');
set(handles.status,'Value',1);

eEmissThresh = get(handles.eEmissThreshBox, 'String');
if(isempty(eEmissThresh))
    error(['The emission threshold for electrical ',...
        'activity has not been set.']);
end

gEmissThresh = get(handles.gEmissThreshBox, 'String');
if(isempty(gEmissThresh))
    error(['The emission threshold for gas',...
        ' concentration has not been set.']);
end

constantK = get(handles.constantKBox, 'String');
if(isempty(constantK))
    error('The constant K value has not been set.');
end

constantC = get(handles.constantCBox, 'String');
if(isempty(constantC))
    error('The constant C value has not been set.');
end

fitThresh = get(handles.fitThreshBox, 'String');
if(isempty(fitThresh))
    error('The fitness threshold has not been set.');
end

maxIter = get(handles.maxIterBox, 'String');
if(isempty(maxIter))
    error('The maximum number of iterations has not been set.');
end

temp1 = get(handles.nomValBox, 'String');
if(regexp(temp1,'\[((\d+)|(\d+\,))+\]'))
    nomValues = strtrim(temp1);
else
    error(['The nominal values field has been incorrectly given. ',...
        'It must be of the form [var,var,var]']);
end

temp2 = get(handles.genotypeBox, 'String');
%'\{((\[((\d+)|(\d+\,))+\])\,)+\}'
if(~isempty(regexp(temp2,...
        '\{[((\[[\d|(\d+\,)]+\])\,)+\}|((\[[\d|(\d+\,)]+\]))\}', 'once')));
    [~,noOfGenes] = size(regexp(temp2,'\]'));
    genotype = strtrim(temp2);
else
    error(['The genotype has been incorrectly given.',...
        'It must be of the form {[var,var,var],...}']);
end

temp3 = get(handles.outputNodesBox, 'String');
if(~isempty(regexp(temp3,'\{((\[[\d|(\d+\,)]+\])\,)+\}', 'once')));
    outputNodes = strtrim(temp3);
else
    error(['The output nodes field has been incorrectly given. ',...
        'It must be of the form [var,var,var]']);
end

temp4 = get(handles.fitFuncBox, 'String');
if(~isempty(regexp(temp4,'\@[\w]+', 'once')))
    fitFunc = strtrim(temp4);
else
    error(['The fitness function has been incorrectly given. ',...
        'It must be of the form ''@...''']);
end

temp5 = get(handles.inFuncBox, 'String');
if(~isempty(regexp(temp5,'\@[\w]+', 'once')))
    inFunc = strtrim(temp5);
else
    error(['The input function has been incorrectly given. ',...
        'It must be of the form ''@...''']);
end

temp6 = get(handles.diffFuncBox, 'String');
if(~isempty(regexp(temp6,'\@[\w]+', 'once')))
    diffFunc = strtrim(temp6);
elseif(isempty(temp6))
    diffFunc = '@gasDiffusion';
else
    diffFunc = '@gasDiffusion';
end

temp7 = get(handles.modFuncBox, 'String');
if(~isempty(regexp(temp7,'\@[\w]+', 'once')))
    modFunc = strtrim(temp7);
elseif(isempty(temp7))
    modFunc = '@gasModulation';
else
    modFunc = '@gasModulation';
end

display = get(handles.displayCheckBox, 'Value');

outputs{1} = zeros(1,noOfGenes);
emissions = zeros(noOfGenes,3);

displayHandles = '[handles.axes1, handles.axes2]';
[finalOutput,finalEmissions,fitness] = eval(['liveGasNet(',genotype,',',...
    eEmissThresh,',',gEmissThresh,',',constantC,',',constantK,',',...
    nomValues,',',int2str(display),',',fitFunc,',',fitThresh,',',...
    inFunc,',','emissions',',','outputs',',','2',',',maxIter,',',...
    outputNodes,',',displayHandles,',',modFunc,',',diffFunc,')']);

[~,c] = size(finalOutput);
status = cell(c,1);
for i=1:c
    tmp = 'Node Output:  ';
    for j=1:noOfGenes
        tmp = [tmp,num2str(finalOutput{i}(j)),'    '];
    end
    status{i,1} = [tmp,'   Fitness: ',num2str(fitness{i})];
end
        
set(handles.status,'String',status);
finalStep = num2str(str2double(maxIter)+2);
set(handles.currentStepBox,'String',finalStep);

%Adding additional data to handles structure:
handles.outputState = finalOutput;
handles.emissState = finalEmissions;
%Saving changes to handles structure:
guidata(hObject,handles);

function genotypeBox_Callback(hObject, eventdata, handles)
% hObject    handle to genotypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of genotypeBox as text
%        str2double(get(hObject,'String')) returns contents of genotypeBox as a double


% --- Executes during object creation, after setting all properties.
function genotypeBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genotypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in genotypeButton.
function genotypeButton_Callback(hObject, eventdata, handles)
% hObject    handle to genotypeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
data{1} = get(handles.genotypeBox,'String');
data{2} = get(handles.nomValBox,'String');
set(handles.mainScreen,'UserData',data);
set(handles.mainScreen,'Visible','off');
genoScreen = GenotypeGUI;
waitfor(genoScreen);
data = get(handles.mainScreen,'UserData');
if(~isempty(data{3}))
    clearHistoryButton_Callback(handles.clearHistoryButton,...
                                                        eventdata,handles);
end
set(handles.genotypeBox,'String',data{1});



% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function mainScreen_CreateFcn(hObject, eventdata, handles)
% hObject    handle to mainScreen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in clearButton.
function clearButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on selection change in status.
function status_Callback(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns status contents as cell array
%        contents{get(hObject,'Value')} returns selected item from status


% --- Executes during object creation, after setting all properties.
function status_CreateFcn(hObject, eventdata, handles)
% hObject    handle to status (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in displayCheckBox.
function displayCheckBox_Callback(hObject, eventdata, handles)
% hObject    handle to displayCheckBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of displayCheckBox



function inFuncBox_Callback(hObject, eventdata, handles)
% hObject    handle to inFuncBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of inFuncBox as text
%        str2double(get(hObject,'String')) returns contents of inFuncBox as a double


% --- Executes during object creation, after setting all properties.
function inFuncBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inFuncBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fitFuncBox_Callback(hObject, eventdata, handles)
% hObject    handle to fitFuncBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fitFuncBox as text
%        str2double(get(hObject,'String')) returns contents of fitFuncBox as a double


% --- Executes during object creation, after setting all properties.
function fitFuncBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fitFuncBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function diffFuncBox_Callback(hObject, eventdata, handles)
% hObject    handle to diffFuncBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of diffFuncBox as text
%        str2double(get(hObject,'String')) returns contents of diffFuncBox as a double


% --- Executes during object creation, after setting all properties.
function diffFuncBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to diffFuncBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function modFuncBox_Callback(hObject, eventdata, handles)
% hObject    handle to modFuncBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of modFuncBox as text
%        str2double(get(hObject,'String')) returns contents of modFuncBox as a double


% --- Executes during object creation, after setting all properties.
function modFuncBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to modFuncBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function gEmissThreshBox_Callback(hObject, eventdata, handles)
% hObject    handle to gEmissThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of gEmissThreshBox as text
%        str2double(get(hObject,'String')) returns contents of gEmissThreshBox as a double


% --- Executes during object creation, after setting all properties.
function gEmissThreshBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to gEmissThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function eEmissThreshBox_Callback(hObject, eventdata, handles)
% hObject    handle to eEmissThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eEmissThreshBox as text
%        str2double(get(hObject,'String')) returns contents of eEmissThreshBox as a double


% --- Executes during object creation, after setting all properties.
function eEmissThreshBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eEmissThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function constantCBox_Callback(hObject, eventdata, handles)
% hObject    handle to constantCBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of constantCBox as text
%        str2double(get(hObject,'String')) returns contents of constantCBox as a double


% --- Executes during object creation, after setting all properties.
function constantCBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to constantCBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function constantKBox_Callback(hObject, eventdata, handles)
% hObject    handle to constantKBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of constantKBox as text
%        str2double(get(hObject,'String')) returns contents of constantKBox as a double


% --- Executes during object creation, after setting all properties.
function constantKBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to constantKBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fitThreshBox_Callback(hObject, eventdata, handles)
% hObject    handle to fitThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fitThreshBox as text
%        str2double(get(hObject,'String')) returns contents of fitThreshBox as a double


% --- Executes during object creation, after setting all properties.
function fitThreshBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fitThreshBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function maxIterBox_Callback(hObject, eventdata, handles)
% hObject    handle to maxIterBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of maxIterBox as text
%        str2double(get(hObject,'String')) returns contents of maxIterBox as a double


% --- Executes during object creation, after setting all properties.
function maxIterBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxIterBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function genoBox_Callback(hObject, eventdata, handles)
% hObject    handle to genotypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of genotypeBox as text
%        str2double(get(hObject,'String')) returns contents of genotypeBox as a double


% --- Executes during object creation, after setting all properties.
function genoBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to genotypeBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function nomValBox_Callback(hObject, eventdata, handles)
% hObject    handle to nomValBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of nomValBox as text
%        str2double(get(hObject,'String')) returns contents of nomValBox as a double


% --- Executes during object creation, after setting all properties.
function nomValBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to nomValBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stepButton.
function stepButton_Callback(hObject, eventdata, handles)
% hObject    handle to stepButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.status,'String','GasNet Running...');
set(handles.status,'Value',1);

eEmissThresh = get(handles.eEmissThreshBox, 'String');
if(isempty(eEmissThresh))
    error(['The emission threshold for electrical ',...
        'activity has not been set.']);
end

gEmissThresh = get(handles.gEmissThreshBox, 'String');
if(isempty(gEmissThresh))
    error(['The emission threshold for gas',...
        ' concentration has not been set.']);
end

constantK = get(handles.constantKBox, 'String');
if(isempty(constantK))
    error('The constant K value has not been set.');
end

constantC = get(handles.constantCBox, 'String');
if(isempty(constantC))
    error('The constant C value has not been set.');
end

fitThresh = get(handles.fitThreshBox, 'String');
if(isempty(fitThresh))
    error('The fitness threshold has not been set.');
end

noOfSteps = 0;
temp1 = get(handles.noOfStepsBox, 'Value');
if(isempty(temp1))
    error('The number of steps has not been set.');
elseif(temp1 == 1), noOfSteps = '1';
elseif(temp1 == 2), noOfSteps = '10';
elseif(temp1 == 3), noOfSteps = '100';
elseif(temp1 == 4), noOfSteps = '1000';
end

currentStep = get(handles.currentStepBox, 'String');
if(isempty(currentStep))
    currentStep = '2';
end

temp2 = get(handles.nomValBox, 'String');
if(~isempty(regexp(temp2,'\[((\d+)|(\d+\,))+\]', 'once')))
    nomValues = strtrim(temp2);
else
    error(['The nominal values field has been incorrectly given. ',...
        'It must be of the form [var,var,var]']);
end

temp3 = get(handles.genotypeBox, 'String');
if(~isempty(regexp(temp3,...
        '\{[((\[[\d|(\d+\,)]+\])\,)+\}|((\[[\d|(\d+\,)]+\]))\}', 'once')));
    [~,noOfGenes] = size(regexp(temp3,'\]'));
    genotype = strtrim(temp3);
else
    error(['The genotype has been incorrectly given.',...
        'It must be of the form {[var,var,var],[var,var,var],...}']);
end

temp4 = get(handles.outputNodesBox, 'String');
if(~isempty(regexp(temp4,'\[((\d+)|(\d+\,))+\]', 'once')))
    outputNodes = strtrim(temp4);
else
    error(['The output nodes field has been incorrectly given. ',...
        'It must be of the form [var,var,var]']);
end

temp5 = get(handles.fitFuncBox, 'String');
if(~isempty(regexp(temp5,'\@[\w]+', 'once')))
    fitFunc = strtrim(temp5);
else
    error(['The fitness function has been incorrectly given. ',...
        'It must be of the form ''@...''']);
end

temp6 = get(handles.inFuncBox, 'String');
if(~isempty(regexp(temp6,'\@[\w]+', 'once')))
    inFunc = strtrim(temp6);
else
    error(['The input function has been incorrectly given. ',...
        'It must be of the form ''@...''']);
end

temp7 = get(handles.diffFuncBox, 'String');
if(~isempty(regexp(temp7,'\@[\w]+', 'once')))
    diffFunc = strtrim(temp7);
elseif(isempty(temp7))
    diffFunc = '@gasDiffusion';
else
    diffFunc = '@gasDiffusion';
end

temp8 = get(handles.modFuncBox, 'String');
if(~isempty(regexp(temp8,'\@[\w]+', 'once')))
    modFunc = strtrim(temp8);
elseif(isempty(temp8))
    modFunc = '@gasModulation';
else
    modFunc = '@gasModulation';
end

display = get(handles.displayCheckBox, 'Value');

if(str2double(currentStep)>2)
    outputs = handles.outputState;
    emissions = handles.emissState;
else
    outputs{1} = zeros(1,noOfGenes);
    emissions = zeros(noOfGenes,3);
end

displayHandles = '[handles.axes1, handles.axes2]';
[finalOutput,finalEmissions,fitness] = eval(['liveGasNet(',genotype,',',...
    eEmissThresh,',',gEmissThresh,',',constantC,',',constantK,',',...
    nomValues,',',int2str(display),',',fitFunc,',',fitThresh,',',...
    inFunc,',','emissions',',','outputs',',',currentStep,',',...
    noOfSteps,',',outputNodes,',',displayHandles,',',modFunc,',',...
    diffFunc,')']);

[~,c] = size(finalOutput);
status = cell(c,1);
for i=1:c
    tmp = 'Node Output:  ';
    for j=1:noOfGenes
        tmp = [tmp,num2str(finalOutput{i}(j)),'    '];
    end
    status{i,1} = [tmp,'   Fitness: ',num2str(fitness{i})];
end
        
set(handles.status,'String',status);
set(handles.currentStepBox,'String',...
                num2str(str2double(currentStep)+str2double(noOfSteps)));

%Adding additional data to handles structure:
handles.outputState = finalOutput;
handles.emissState = finalEmissions;
%Saving changes to handles structure:
guidata(hObject,handles);



% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in noOfStepBox.
function noOfStepBox_Callback(hObject, eventdata, handles)
% hObject    handle to noOfStepBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns noOfStepBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from noOfStepBox


% --- Executes during object creation, after setting all properties.
function noOfStepBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noOfStepBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in clearHistoryButton.
function clearHistoryButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearHistoryButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Clear figures and status boxes.
cla(handles.axes1);
cla(handles.axes2);
set(handles.status,'String',' ');
set(handles.status,'Value',1)
set(handles.currentStepBox,'String','');

%Clearing emission and output state data from handles structure:
if(~isempty(handles.outputState))
    emptyOutputs{1} = zeros(size(handles.outputState(1)));
    emptyEmissions = zeros(size(handles.emissState));
    handles.outputState = emptyOutputs;
    handles.emissState = emptyEmissions;
end
%Saving changes to handles structure:
guidata(hObject,handles);


% --- Executes on selection change in noOfStepsBox.
function noOfStepsBox_Callback(hObject, eventdata, handles)
% hObject    handle to noOfStepsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns noOfStepsBox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from noOfStepsBox


% --- Executes during object creation, after setting all properties.
function noOfStepsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noOfStepsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optimiseButton.
function optimiseButton_Callback(hObject, eventdata, handles)
% hObject    handle to optimiseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

eEmissThresh = get(handles.eEmissThreshBox, 'String');
if(isempty(eEmissThresh))
    error(['The emission threshold for electrical ',...
        'activity has not been set.']);
end

gEmissThresh = get(handles.gEmissThreshBox, 'String');
if(isempty(gEmissThresh))
    error(['The emission threshold for gas',...
        ' concentration has not been set.']);
end

constantK = get(handles.constantKBox, 'String');
if(isempty(constantK))
    error('The constant K value has not been set.');
end

constantC = get(handles.constantCBox, 'String');
if(isempty(constantC))
    error('The constant C value has not been set.');
end

fitThresh = get(handles.fitThreshBox, 'String');
if(isempty(fitThresh))
    error('The fitness threshold has not been set.');
end

maxIter = get(handles.maxIterBox, 'String');
if(isempty(maxIter))
    error('The maximum number of iterations has not been set.');
end

temp2 = get(handles.nomValBox, 'String');
if(~isempty(regexp(temp2,'\[((\d+)|(\d+\,))+\]', 'once')))
    nomValues = strtrim(temp2);
else
    error(['The nominal values field has been incorrectly given. ',...
        'It must be of the form [var,var,var]']);
end

temp3 = get(handles.genotypeBox, 'String');
if(~isempty(regexp(temp3,...
        '\{[((\[[\d|(\d+\,)]+\])\,)+\}|((\[[\d|(\d+\,)]+\]))\}', 'once')));
    [~,noOfGenes] = size(regexp(temp3,'\]'));
    genotype = strtrim(temp3);
else
    error(['The genotype has been incorrectly given.',...
        'It must be of the form {[var,var,var],[var,var,var],...}']);
end

temp4 = get(handles.outputNodesBox, 'String');
if(~isempty(regexp(temp4,'\[((\d+)|(\d+\,))+\]', 'once')))
    outputNodes = strtrim(temp4);
else
    error(['The output nodes field has been incorrectly given. ',...
        'It must be of the form [var,var,var]']);
end

temp5 = get(handles.fitFuncBox, 'String');
if(~isempty(regexp(temp5,'\@[\w]+', 'once')))
    fitFunc = strtrim(temp5);
else
    error(['The fitness function has been incorrectly given. ',...
        'It must be of the form ''@...''']);
end

temp6 = get(handles.inFuncBox, 'String');
if(~isempty(regexp(temp6,'\@[\w]+', 'once')))
    inFunc = strtrim(temp6);
else
    error(['The input function has been incorrectly given. ',...
        'It must be of the form ''@...''']);
end

temp7 = get(handles.diffFuncBox, 'String');
if(~isempty(regexp(temp7,'\@[\w]+', 'once')))
    diffFunc = strtrim(temp7);
elseif(isempty(temp7))
    diffFunc = '@gasDiffusion';
else
    diffFunc = '@gasDiffusion';
end

temp8 = get(handles.modFuncBox, 'String');
if(~isempty(regexp(temp8,'\@[\w]+', 'once')))
    modFunc = strtrim(temp8);
elseif(isempty(temp8))
    modFunc = '@gasModulation';
else
    modFunc = '@gasModulation';
end
 
% The following code produces an input popup box.
prompt = {'Enter mu (mutation percentage 1-100):',...
    'Enter maximum number of epochs:',...
    'Enter population plane width (i.e. 10 = 10x10):',...
    ['Enter initial number of nodes(genes) for each genotype',...
                                      '(only used from random start)'],...
    'Enter the number of values per gene:',...
    'Enter a logical array describing which gene values are mutable',...
    ['Evolve from genotype specified in main',...
                                  'screen (random otherwise): y/n'],...
    ['Enter array describing the which nodes of the starting genotype',...
    'are fixed and cannot be removed during mutation. 0 = can be ',...
    ' removed, 1 = fixed but gene values can be mutated using',...
    'isMutable, 2 = fixed and non-mutatable. All fixed nodes should',...
    'be at the start of the genotype.']};
dlg_title = 'GA Set-up';
num_lines = 1;
temp = '[';
for i=1:noOfGenes-1; temp = [temp,'0,']; end;
temp = [temp,'0]'];
def = {'4','1000','10','5','16','[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0]',...
                                                                'y',temp};
answer = inputdlg(prompt,dlg_title,num_lines,def);


if(~isempty(answer))
    if(str2double(answer{1})<1 || str2double(answer{1})>100)
        error('Value for mu must be between 1-100.');
    end
    if(isempty(regexp(answer{2},'[\d]+', 'once'))||str2double(answer{2})<3)
        error('Maximum number of epochs must be a number & < 3');
    end
    if(mod(str2double(answer{3}),2))
        error('Population width must be even.');
    end
    if(isempty(regexp(answer{4},'[\d]+', 'once')))
        error('Initial number of nodes must be a number.');
    end
    if(isempty(regexp(answer{5},'[\d]+', 'once')))
        error('Number of gene values must be a number.');
    end
    if(isempty(regexp(answer{6},'\[([\1|\0])|([\1\,|\0\,]))+\]', 'once')))
        error('''is mutable'' array must be in the form [1,1,0,...].');
    end
    if(isempty(regexp(answer{7},'[\y|\\n]', 'once')))
        error('Choice for specified genotype start should be y or n.');
    end
    if(answer{7} == 'y' && ...
                isempty(regexp(answer{8},'\[((\d+)|(\d+\,))+\]', 'once')))
        error('Choice for specified genotype start should be y or n.');
    end
    
    if(answer{7} == 'y')
        [pop, fitness, stats] = eval(['optimiseGasNet(',fitFunc,',',...
            fitThresh,',',answer{3},',',answer{4},',',answer{5},',',...
            answer{1},',',answer{6},',',answer{8},',',answer{2},',',...
            eEmissThresh,',',gEmissThresh,',',constantC,',',constantK,...
            ',',nomValues,',',maxIter,',',inFunc,',',outputNodes,',',...
            modFunc,',',diffFunc,',',genotype,')']);
    else
        [pop, fitness, stats] = eval(['optimiseGasNet(',fitFunc,',',...
            fitThresh,',',answer{3},',',answer{4},',',answer{5},',',...
            answer{1},',',answer{6},',',answer{2},',',eEmissThresh,',',...
            gEmissThresh,',',constantC,',',constantK,',',nomValues,',',...
            maxIter,',',inFunc,',',outputNodes,',',modFunc,',',...
            diffFunc,')']);
    end
    
    statusOutput = cell((str2double(answer{2})*2)+5,1);
    statusOutput{1,1} = ['Evolutionary results: peak individual is ',...
        'listed first followed by all members of the population ',...
        'followed by their fitness.'];
    statusOutput{2,1} = ['The above left image is a colour',...
        ' map of the population space and the above right image plots',...
        ' the average fitness (blue) against the peak fitness (red).'];
    outCount = 6;
    individualCount = 1;
    maxIndividual = 1;
    maxFitI = 0;
    maxFitJ = 0;
    maxFit = 0;
    for i=1:str2double(answer{3})
        for j=1:str2double(answer{3})
            [~,noOfNodes] = size(pop{i,j});
            if(fitness(i,j)>maxFit)
                maxFit = fitness(i,j);
                maxFitI = i;
                maxFitJ = j;
                maxIndividual = individualCount;
            end
            
            statusOutput{outCount,1} = ['Individual no: ',...
                num2str(individualCount), '     Fitness: ',...
                num2str(fitness(i,j))];
            outCount = outCount + 1;
            
            temp1 = '{';
            for k=1:noOfNodes
                str1 = mat2str(pop{i,j}{k});
                str2 = regexprep(str1,' ',',');
                if(k<noOfNodes)
                    temp1 = [temp1,str2,','];
                else
                    temp1 = [temp1,str2];
                end
            end
            temp1 = [temp1,'}'];
            statusOutput{outCount,1} = temp1;
            individualCount = individualCount+1;
            outCount = outCount + 1;
        end
    end
    
    statusOutput{3,1} = ['Individual no: ',...
        num2str(maxIndividual), '     Fitness: ',...
        num2str(maxFit)];

    [~,noOfNodes] = size(pop{maxFitI,maxFitJ});
    temp2 = '{';
    for k=1:noOfNodes
        str1 = mat2str(abs(pop{maxFitI,maxFitJ}{k}));
        str2 = regexprep(str1,' ',',');
        if(k<noOfNodes)
            temp2 = [temp2,str2,','];
        else
            temp2 = [temp2,str2];
        end
    end
    temp2 = [temp2,'}'];
    statusOutput{4,1} = temp2;
    statusOutput{5,1} = ' ';
    
    set(handles.status,'String',statusOutput);
    
    cla(handles.axes1);
    axes(handles.axes1);
    imagesc(flipud(fitness));
    caxis([0 1]);
    colormap default;
    axis tight;
    colorbar; 
  
    
    cla(handles.axes2);
    axes(handles.axes2);
    hold on;
    axis([1 (str2double(answer{2})-1) 0 1])
    plot(1:(str2double(answer{2})-1),stats(:,1),'b-')
    plot(1:(str2double(answer{2})-1),stats(:,2),'r-')
    hold off;
end


function outputNodesBox_Callback(hObject, eventdata, handles)
% hObject    handle to outputNodesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of outputNodesBox as text
%        str2double(get(hObject,'String')) returns contents of outputNodesBox as a double


% --- Executes during object creation, after setting all properties.
function outputNodesBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to outputNodesBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
