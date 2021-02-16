function varargout = sleepScoring(varargin)
%   Húmë (formally sleepSMG) ? Open-source MATLAB Sleep Scoring Toolbox
%
%   User-feedback welcomed: jared_saletin@brown.edu
%
%   AUTHORSHIP:
%
%   Jared M. Saletin, PhD (1, 2) and Stephanie M. Greer, PhD (2) E-Mails:
%   jared_saletin@brown.edu , smgreer@gmail.com

%       (1) Department of Psychiatry and Human Behavior, Alpert Medical
%       School of Brown University
%
%       (2) Depeartment of Psychology / Helen Wills Neuroscience Institute,
%       University of California at Berkeley
%
%   Copyright (c) 2015 Jared M. Saletin, PhD and Stephanie M. Greer, PhD
%
%   DESCRIPTION:
%
%   Húmë (formally sleepSMG) is an open-source MATLAB toolbox for
%   processing and analyzing polysomnographic sleep recordings including:
%   sleep staging, plotting, sleep statistics, data management, and event
%   marking routines. Húmë is open-source and licensed under version 3 of
%   the GNU Genral Public License (see below).
%
%   Húmë is deisnged to be compatable with, and makes extensive use of,
%   existing signal processing tools provided both in MATLAB and through
%   the EEGLAB toolbox (http://sccn.ucsd.edu/eeglab/). A working
%   distribution of EEGLAB is included with Húmë in accordance with the GNU
%   General Public License version 2 provided with EEGLAB. EEGLAB is
%   copyrighted to Arnaud Delorme and Scott Makeig, Salk Institute. The
%   original EEGLAB license is included with this software.
%
%   LICENSE AND USE:
%
%   This program is free software: you can redistribute it and/or modify it
%   under the terms of the GNU General Public License as published by the
%   Free Software Foundation, either version 3 of the License, or (at your
%   option) any later version.
% 
%   This program is distributed in the hope that it will be useful, but
%   WITHOUT ANY WARRANTY; without even the implied warranty of
%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%   General Public License for more details.
% 
%   You should have received a copy of the GNU General Public License along
%   with this program.  If not, see <http://www.gnu.org/licenses/>.
%
%   Húmë is intended for research purposes only. Any commercial or medical
%   use of this software is prohibited. The authors accept no
%   responsibility for its use in this manner.
%%

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @sleepScoring_OpeningFcn, ...
    'gui_OutputFcn',  @sleepScoring_OutputFcn, ...
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


% --- Executes just before sleepScoring is made visible.
function sleepScoring_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sleepScoring (see VARARGIN)

% Set Montage List based on montage directory

sleepPath = which('hume');

montageNames = dir(fullfile(fileparts(sleepPath), 'montages'));
montages = [];
for i = 1:length(montageNames)
    if(strfind(montageNames(i).name, '_Montage.m'))
        montages{length(montages) + 1} = montageNames(i).name(1:(end - 2));
    end
end
set(handles.plotSleepIN, 'String', montages)

% Set Events
LUT = eventLUT;
set(handles.EventType, 'String', LUT(:,2));

% Set show events
set(handles.showEvents,'State', 'on');

eval(['handles.CurrMontage = ',montages{1}, ';']);

% Set Notes list based on notes directory
noteNames = dir(fullfile(fileparts(sleepPath), 'coreFunctions/noteReader'));
notes = {'Notes'};
for i = 1:length(noteNames)
    if(strfind(noteNames(i).name, '_LoadNotes.m'))
        notes{length(notes) + 1} = noteNames(i).name(1:(end - 2));
    end
end
set(handles.twinNotes, 'String', notes)

% Choose default command line output for sleepScoring
handles.output = hObject;
fprintf(1,'\n\nWelcome to Húmë! Happy Scoring!\n\n');

% Set events to on
set(handles.showEvents, 'State', 'on');
handles.plotEvents = 1;
% Update handles structure
guidata(hObject, handles);





% UIWAIT makes sleepScoring wait for user response (see UIRESUME)
% uiwait(handles.humeWindow);


% --- Outputs from this function are returned to the command line.
function varargout = sleepScoring_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%% Key Board short cuts for scoring + buttons

function humeWindow_KeyPressFcn(hObject, eventdata, handles)

if isfield(handles,'stageData')
    
    cStr = get(hObject, 'CurrentCharacter');
    c = str2num(cStr);
    if(~isempty(c) && c >= 0 && c <=6)
        handles = updateStage(handles, c);
        guidata(hObject, handles);
        arrowRightB_Callback(handles.arrowRightB, [], handles);
    elseif(strcmp(cStr, '.'))
        handles = updateStage(handles, 7);
        guidata(hObject, handles);
        arrowRightB_Callback(handles.arrowRightB, [], handles);
    elseif(c == 7)
        arrowLeftB_Callback(handles.arrowLeftB, [], handles);
    elseif(c == 9) 
        arrowRightB_Callback(handles.arrowRightB, [], handles);
    elseif(strcmp(cStr, 'x'))
        Artifact_Callback(handles.Artifact, [], handles);
    elseif(strcmp(eventdata.Key, 'leftarrow'))
        arrowLeftB_Callback(handles.arrowLeftB, [], handles);
    elseif(strcmp(eventdata.Key, 'rightarrow'))
        arrowRightB_Callback(handles.arrowRightB, [], handles);
    elseif(strcmp(cStr, 'e'))
        eventMark(hObject, [], handles);
    elseif(strcmp(cStr, 'E'))
        eventRemove(hObject, [], handles);
    end
    
    
end

% --- Executes on button press in wakeB.
function wakeB_Callback(hObject, eventdata, handles)
% hObject    handle to wakeB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateStage(handles, 0);
guidata(hObject, handles);
arrowRightB_Callback(handles.arrowRightB, [], handles);

% --- Executes on button press in stage1B.
function stage1B_Callback(hObject, eventdata, handles)
% hObject    handle to stage1B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateStage(handles, 1);
guidata(hObject, handles);
arrowRightB_Callback(handles.arrowRightB, [], handles);

% --- Executes on button press in stage2B.
function stage2B_Callback(hObject, eventdata, handles)
% hObject    handle to stage2B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateStage(handles, 2);
guidata(hObject, handles);
arrowRightB_Callback(handles.arrowRightB, [], handles);

% --- Executes on button press in stage3B.
function stage3B_Callback(hObject, eventdata, handles)
% hObject    handle to stage3B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateStage(handles, 3);
guidata(hObject, handles);
arrowRightB_Callback(handles.arrowRightB, [], handles);

% --- Executes on button press in stage4B.
function stage4B_Callback(hObject, eventdata, handles)
% hObject    handle to stage4B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateStage(handles, 4);
guidata(hObject, handles);
arrowRightB_Callback(handles.arrowRightB, [], handles);

% --- Executes on button press in remB.
function remB_Callback(hObject, eventdata, handles)
% hObject    handle to remB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateStage(handles, 5);
guidata(hObject, handles);
arrowRightB_Callback(handles.arrowRightB, [], handles);

% --- Executes on button press in mtB.
function mtB_Callback(hObject, eventdata, handles)
% hObject    handle to mtB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = updateStage(handles, 6);
guidata(hObject, handles);
arrowRightB_Callback(handles.arrowRightB, [], handles);

%% Navigation Buttons

function axes2_ButtonDownFcn(hObject, eventdata, handles)
pt = get(hObject, 'currentPoint');

winSize = str2num(get(handles.winIN, 'String'));
srate = handles.EEG.srate;
ptX = floor(pt(1)*(60*60/winSize))*winSize*srate;
jumpto(handles, ptX)

function jumpto(handles, ptX)
winSize = str2num(get(handles.winIN, 'String'));
srate = handles.EEG.srate;

newX = [ptX+1, ptX+winSize*srate];
range = newX(1):newX(2);
handles = plotSleepData(handles, range);
updateStage(handles, []);


% --- Executes on button press in arrowLeftB.
function arrowLeftB_Callback(hObject, eventdata, handles)
% hObject    handle to arrowLeftB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winSize = str2num(get(handles.winIN, 'String'));
srate = handles.EEG.srate;
curX = xlim(handles.axes1);
newX = [curX(1) - winSize*srate, curX(1) - 1];

range = newX(1):newX(2);

handles = plotSleepData(handles, range);
updateStage(handles, []);

% --- Executes on button press in arrowRightB.
function arrowRightB_Callback(hObject, eventdata, handles)
% hObject    handle to arrowRightB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winSize = str2num(get(handles.winIN, 'String'));
srate = handles.EEG.srate;
curX = xlim(handles.axes1);
newX = [curX(2) + 1, curX(2) + winSize*srate];
range = newX(1):newX(2);

handles = plotSleepData(handles, range);
updateStage(handles, []);

%%


function fileIN_Callback(hObject, eventdata, handles)
% hObject    handle to fileIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fileIN as text
%        str2double(get(hObject,'String')) returns contents of fileIN as a
%        double

% --- Executes during object creation, after setting all properties.
function fileIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% Load
% --- Executes on button press in loadB.
function loadB_Callback(hObject, eventdata, handles)
% hObject    handle to loadB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%get EEG data
set(handles.sleepSetPan, 'Visible', 'off')
filename = get(handles.fileIN, 'String');

if(strcmp(filename((end - 3):end), '.mat'))
    load(filename);
elseif(strcmp(filename((end - 3):end), '.edf') || strcmp(filename((end - 3):end), '.EDF'))
    EEG = pop_biosig(filename);
    set(handles.recStartIN,'String',datestr(EEG.etc.T0,'HHMMSS.FFF'));
elseif(strcmp(filename((end - 3):end), '.set'))
    %cc
%     EEG = pop_loadset(filename);
    [fpath,fname,fext] = fileparts(filename);
    EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    
    %     EEG = pop_loadset(filename);
    set(handles.recStartIN,'String',datestr(EEG.etc.T0,'HHMMSS.FFF'));
    dd = datetime(EEG.etc.T0);
    set(handles.lightsoffIN, 'String', datestr(dd + seconds(30*3), 'HHMMSS.FFF'))% assumo luci accese 3 pagine da 30 secondi dopo inizio registrazine
    set(handles.lightsonIN, 'String', datestr(dd + seconds(EEG.xmax), 'HHMMSS.FFF'))
    
    
    
    
else
    display('CAN NOT OPEN FILE: don''t recognise file ending')
end

handles.EEG = EEG;
pack

%look for stage data
filename = get(handles.stageFileIN, 'String');
if(exist(filename))
    stageData = loadStaging(handles, filename);
    if isempty(stageData)
        stageData.srate = EEG.srate;
    end
else
    stageData = [];
    stageData.srate = EEG.srate;
end

if(strcmp(get(handles.twinNotesS, 'Enable'), 'on'))
    
    if(exist(get(handles.twinNotesS, 'String')))
        file = get(handles.twinNotesS, 'String');
        
        noteFCN = get(handles.twinNotes, 'String');
        boxInd = get(handles.twinNotes, 'Value');
        eval(['stageData = ', noteFCN{boxInd}, '(stageData, file);']);
        
        stageData = loadStaging(handles, stageData);
    else
        fprinf('Can''t use twin notes file because it doesn''t exist')
    end
end

set(handles.sleepSetPan, 'Visible', 'on')
handles.stageData = stageData;
guidata(hObject, handles)


% --- Executes on button press in startB.
function startB_Callback(hObject, eventdata, handles)
% hObject    handle to startB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.setupPan, 'Visible', 'off')
set(handles.sleepSetPan, 'Visible', 'off')
handles.hideChans = handles.CurrMontage.hideChans;
handles.scaleChans = handles.CurrMontage.scaleChans;
handles.curScale = 150;
handles.showComp = 0;
guidata(hObject, handles)

[stagePath, stageName, stageEXT]=fileparts(get(handles.stageFileIN,'String'));
[eegPath, eegName, eegEXT]=fileparts(get(handles.fileIN,'String'));
set(handles.humeWindow,'Name',sprintf('Húmë Scoring: [PSG File: %s, Score File: %s]',[eegName,eegEXT], [stageName,stageEXT]));

handles = initStaging(handles);

exit =  0;
while exit == 0
    
    mont = listdlg('ListString', handles.plotSleepIN.String, 'Name', 'Pick a Montage', 'SelectionMode', 'single');
    if isempty(mont)
        return
    end
    
    try
        set(handles.plotSleepIN, 'Value', mont);
        plotFCN = get(handles.plotSleepIN, 'String');
        boxInd = get(handles.plotSleepIN, 'Value');
        eval(['handles.CurrMontage = ',plotFCN{boxInd}, '(handles);']);
        guidata(hObject, handles);
        runPlot(handles)
        updateStage(handles, []);
        exit = 1;
    catch
        waitfor(msgbox('Montage is incompatible. Try again'));
    end
end





function stageData = loadStaging(handles, stageFile)
if(~isstruct(stageFile))
    load(stageFile)
else
    stageData = stageFile;
end

if ~exist('stageData')
    stageData=[];
end

if(isfield(stageData, 'win'))
    set(handles.winIN, 'String', num2str(stageData.win))
    set(handles.winIN, 'Enable', 'off')
end
if(isfield(stageData, 'lightsON'))
    set(handles.lightsonIN, 'String', datestr(stageData.lightsON, 'HHMMSS.FFF'))
end
if(isfield(stageData, 'lightsOFF'))
    set(handles.lightsoffIN, 'String', datestr(stageData.lightsOFF, 'HHMMSS.FFF'))
end
if(isfield(stageData, 'recStart'))
    set(handles.recStartIN, 'String', datestr(stageData.recStart, 'HHMMSS.FFF'))
end
if(isfield(stageData, 'Notes'))
    set(handles.notesIN, 'String', stageData.Notes)
end


function runPlot(handles)
winSize = str2num(get(handles.winIN, 'String'));
srate = handles.EEG.srate;

range = 1:(winSize*srate);
handles = plotSleepData(handles, range);


function handles = initStaging(handles)
winSize = str2num(get(handles.winIN, 'String'));
srate = handles.EEG.srate;

%set stage info to user input
handles.stageData.win = str2num(get(handles.winIN, 'String'));

handles.stageData.recStart = datenum(get(handles.recStartIN, 'String'), 'HHMMSS.FFF');
handles.stageData.lightsON = datenum(get(handles.lightsonIN, 'String'), 'HHMMSS.FFF');
%Add a day to the time if it looks like lights on happened before the
%record start.
if(~(handles.stageData.recStart < handles.stageData.lightsON))
    handles.stageData.lightsON = handles.stageData.lightsON + 1;
end
handles.stageData.lightsOFF = datenum(get(handles.lightsoffIN, 'String'), 'HHMMSS.FFF');
%Add a day to the time if it looks like lights on happened before the
%record start.
if(~(handles.stageData.recStart < handles.stageData.lightsOFF))
    handles.stageData.lightsOFF = handles.stageData.lightsOFF + 1;
end

handles.stageData.srate = srate;
if(~isfield(handles.stageData, 'Notes'))
    handles.stageData.Notes = '';
end

if(~isfield(handles.stageData, 'stages'))
    handles.stageData.stages = ones(ceil(size(handles.EEG.data, 2)/(winSize*srate)), 1)*7;
    handles.stageData.onsets = zeros(ceil(size(handles.EEG.data, 2)/(winSize*srate)), 1);
    handles.stagePlot = zeros(ceil(size(handles.EEG.data, 2)/(winSize*srate)), 1);
else
    
    handles.stagePlot = zeros(size(handles.stageData.stages, 1), 1);
    for i = 1:size(handles.stageData.stages, 1)
        stageCode = handles.stageData.stages(i, 1);
    end
end
handles.stageData.stageTime = (0:(size(handles.stageData.stages, 1) - 1))./(60/winSize);

if(isfield(handles, 'compStage'))
    tmp = ones(size(handles.stageData.stages))*7;
    tmp(1:length(handles.compStage)) = handles.compStage;
    handles.compStage = tmp;
end


function handles = updateStage(handles, stageCode)


winSize = handles.stageData.win;
srate = handles.stageData.srate;

curWin = xlim(handles.axes1);
ind = floor(curWin(2)/(winSize*handles.EEG.srate));

rstart = handles.stageData.recStart + (floor(curWin(1)/handles.EEG.srate)/86400);
set(handles.timeS, 'String', sprintf('Time: %s Epoch: %d', datestr(rstart, 'HH:MM:SS'), ind));

onT = etime(datevec(handles.stageData.lightsON), datevec(handles.stageData.recStart))/60;
offT = etime(datevec(handles.stageData.lightsOFF), datevec(handles.stageData.recStart))/60;

if(~isempty(stageCode))
    handles.stageData.stages(ind, 1) = stageCode;
    handles.stageData.onsets(ind, 1) = curWin(1);
else
    stageCode = handles.stageData.stages(ind, 1);
    %stageCodeC = handles.stageData.stages(ind, 1);
end
stageCodeC = -1;

hold(handles.axes2, 'off')
curT = handles.stageData.stageTime(ind)./60;
plot(handles.axes2, [curT, curT], [0, 7], 'k');
hold(handles.axes2, 'on')
plot(handles.axes2, [onT, onT]./60, [0, 7], 'r', 'LineWidth', 2);
plot(handles.axes2, [offT, offT]./60, [0, 7], 'g', 'LineWidth', 2);

% plotmap = [7 4 3 2 1 5 6 0];
plotmap = [6 5 4 3 2 1 7 0];
%stageColors = [0 0 0; 102 255 255; 0 158 225; 102 102 255; 128 0 255; 255 0 0; 100 100 100; 0 0 0]./255;
stageColors = [0 0 0; 102 255 255; 0 158 225; 102 102 255; 128 0 255; 255 0 0; 100 100 100; 200 200 200]./255;

stageNames = {'wake'; 'stage1'; 'stage2'; 'stage3'; 'stage4'; 'rem'; 'mt'};

for i = 0:7;
    curInds = find(handles.stageData.stages == i);
    
    plot(handles.axes2, handles.stageData.stageTime(curInds)./60, ones(length(curInds), 1)*plotmap(i + 1), '.', 'MarkerSize', 20, 'Color', stageColors(i+1, :));
    %          plot(handles.axes2, [handles.stageData.stageTime(curInds(c)), handles.stageData.stageTime(curInds(c))], [plotmap(i+1)-.5, plotmap(i+1)+.5], 'Color', stageColors(i+1, :), 'LineWidth', .1);
    %
    %     %     if(isfield(handles, 'compStage') && handles.showComp)
    % %         compInds = find(handles.compStage == i & handles.stageData.stages ~= 7);
    % %         plot(handles.axes2, handles.stageData.stageTime(compInds), ones(length(compInds), 1)*plotmap(i + 1), 'o', 'MarkerSize', 7, 'Color', stageColors(i+1, :)*.5);
    % %         stageCodeC = handles.compStage(ind, 1);
    
    connectData(curInds) = plotmap(i + 1);
    
    
    %     end
    if(i < 7)
        b = eval(['handles.', stageNames{i + 1}, 'B']);
        curX = xlim(handles.axes2);
        if(i == stageCode)
            set(b, 'BackgroundColor', stageColors(i + 1, :));
            if stageCode == 0
                set(b,'ForegroundColor', [1 1 1]);
            end
            plot(handles.axes2, 1/60, plotmap(i + 1), '<', 'Color', stageColors(i + 1, :), 'MarkerSize', 7, 'LineWidth', 3)
        else
            set(b, 'BackgroundColor', [1 1 1]);
            set(b,'ForegroundColor', [0 0 0]);
        end
        if(i == stageCodeC && (stageCode < 7) && handles.showComp)
            %set(b, 'BackgroundColor', stageColors(i + 1, :)*.5);
            plot(handles.axes2, curX(2)/100, plotmap(i + 1), '<', 'Color', stageColors(i + 1, :), 'MarkerSize', 7, 'LineWidth', 3)
        end
    end
end

plot(handles.axes2, handles.stageData.stageTime./60, connectData, 'k')
set(handles.axes2, 'Xlim', handles.stageData.stageTime([1, end])./60, 'Ylim', [0, 7], 'YTick', 0:7, 'YTickLabel', {'ANOM'; 'REM'; 'Stage4'; 'Stage3'; 'Stage2'; 'Stage1'; 'Wake'; 'MT'})
set(handles.axes2, 'ButtonDownFcn', 'sleepScoring(''axes2_ButtonDownFcn'',gcbo,[],guidata(gcbo))')
guidata(handles.axes2, handles)

handles.stageData.Notes = get(handles.notesIN, 'String');
stageData = handles.stageData;
%save(get(handles.stageFileIN, 'String'), 'stageData');



function stageFileIN_Callback(hObject, eventdata, handles)
% hObject    handle to stageFileIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of stageFileIN as text
%        str2double(get(hObject,'String')) returns contents of stageFileIN as a double


% --- Executes during object creation, after setting all properties.
function stageFileIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stageFileIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% record info text inputs

function recStartIN_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function recStartIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to recStartIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function lightsonIN_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
function lightsonIN_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function lightsoffIN_Callback(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.

function lightsoffIN_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function winIN_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function winIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to winIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% entering Notes


function notesIN_Callback(hObject, eventdata, handles)
% hObject    handle to notesIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of notesIN as text
%        str2double(get(hObject,'String')) returns contents of notesIN as a double


% --- Executes during object creation, after setting all properties.
function notesIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to notesIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in closeNotesB.
function closeNotesB_Callback(hObject, eventdata, handles)
% hObject    handle to closeNotesB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.notePan, 'Visible', 'off')
handles.stageData.Notes = get(handles.notesIN, 'String');

if(length(fields(handles.stageData)) >= 9)
    stageData = handles.stageData;
    %save(get(handles.stageFileIN, 'String'), 'stageData');
end


%% Marking cursur
function txt = cursorInfoUpdate(~, cursorData, handles)
chanScale = str2double(parseTag(get(cursorData.Target, 'Tag'), 'scale'));
chan = chanScale/150;

position = cursorData.Position;
timeP =  cursorData.Position(1)/handles.EEG.srate;
amp = (cursorData.Position(2) - chanScale);
if(isempty(amp))
    txt = sprintf(get(cursorData.Target, 'Tag'));
else
    txt = sprintf('Amp: %.1f\nT: %.3f', (amp*-1)/(150/str2num(handles.CurrMontage.scale{chan})), timeP);
end

function markStr_Callback(hObject, eventdata, handles)
% hObject    handle to markStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of markStr as text
%        str2double(get(hObject,'String')) returns contents of markStr as a double
%handles.cursor = datacursormode(gcf);



% --- Executes during object creation, after setting all properties.
function markStr_CreateFcn(hObject, eventdata, handles)
% hObject    handle to markStr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in setMark.
function setMark_Callback(hObject, eventdata, handles)
% hObject    handle to setMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cursorData = getCursorInfo(handles.cursor);
label = get(handles.markStr, 'String');
cursTag = str2double(parseTag(get(cursorData.Target, 'Tag'), 'scale'));

scales = handles.CurrMontage.scale;

eventData = {label, cursorData.Position(1), ...
    ceil(cursorData.Position(1)/handles.stageData.srate/handles.stageData.win), ...
    (cursorData.Position(2) - cursTag)*-1/(150/str2num(scales{cursTag/150}))};

if ~isfield(handles.stageData, 'MarkedEvents')
    handles.stageData.MarkedEvents = eventData;
else
    handles.stageData.MarkedEvents = [handles.stageData.MarkedEvents; eventData];
end

guidata(hObject, handles)
if(length(fields(handles.stageData)) >= 9)
    stageData = handles.stageData;
    %save(get(handles.stageFileIN, 'String'), 'stageData');
end

curX = xlim(handles.axes1);
range = curX(1):curX(2);
handles = plotSleepData(handles, range);

% --- Executes on button press in delMark.
function delMark_Callback(hObject, eventdata, handles)
% hObject    handle to delMark (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cursorData = getCursorInfo(handles.cursor);
label = get(cursorData.Target, 'Tag');

index = find(and(strcmp(handles.stageData.MarkedEvents(:,1),label),[handles.stageData.MarkedEvents{:,2}]'==cursorData.Position(1)));
handles.stageData.MarkedEvents(index,:)=[];
    
curX = xlim(handles.axes1);
range = curX(1):curX(2);
handles = plotSleepData(handles, range);
guidata(hObject, handles);


% --- Executes on button press in slopeB.
function slopeB_Callback(hObject, eventdata, handles)
% hObject    handle to slopeB (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

cursorData = getCursorInfo(handles.cursor);
chan = str2double(parseTag(get(cursorData.Target, 'Tag'), 'chan'));
midPt = cursorData.Position(1);

slopeData = handles.EEG.data(chan, (midPt - .25*handles.EEG.srate):(midPt + .25*handles.EEG.srate));
xData = ((midPt - .25*handles.EEG.srate):(midPt + .25*handles.EEG.srate))/handles.EEG.srate;
slp = polyfit(xData', slopeData',1);

set(handles.optText, 'String', sprintf('%.2f', slp(1)))

%% Notes

function twinNotes_Callback(hObject, eventdata, handles)
items = get(hObject, 'String');
val = get(hObject, 'Value');

if(strcmp(items{val}, 'Notes'))
    set(handles.twinNotesS, 'enable', 'off')
    set(handles.browse_note_B, 'enable', 'off')
else
    set(handles.twinNotesS, 'enable', 'on')
    set(handles.browse_note_B, 'enable', 'on')
end


function twinNotesS_Callback(hObject, eventdata, handles)
% hObject    handle to twinNotesS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of twinNotesS as text
%        str2double(get(hObject,'String')) returns contents of twinNotesS as a double


% --- Executes during object creation, after setting all properties.
function twinNotesS_CreateFcn(hObject, eventdata, handles)
% hObject    handle to twinNotesS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%% browse files

% --- Executes on button press in browse_slp_B.
function browse_slp_B_Callback(hObject, eventdata, handles)
% hObject    handle to browse_slp_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, filePath] = uigetfile({'*.mat','MAT-files (*.mat)'; '*.edf','EDF-files (*.edf)'; '*.set', 'EEGLAB (*.set)'; '*.*',  'All Files (*.*)'}, 'Sleep Data File');
set(handles.fileIN, 'String', fullfile(filePath,fileName));

% --- Executes on button press in browse_stg_B.
function browse_stg_B_Callback(hObject, eventdata, handles)
% hObject    handle to browse_stg_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, filePath] = uigetfile({'*.mat','MAT-files (*.mat)'; '*.*',  'All Files (*.*)'}, 'Sleep Stage File');
set(handles.stageFileIN, 'String', fullfile(filePath,fileName));

% --- Executes on button press in load_Stg_B.
function load_Stg_B_Callback(hObject, eventdata, handles)
% hObject    handle to load_Stg_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, filePath] = uiputfile({'*.mat','MAT-files (*.mat)'; '*.*',  'All Files (*.*)'}, 'Sleep Stage File');
set(handles.stageFileIN, 'String', fullfile(filePath,fileName));

% --- Executes on button press in browse_note_B.
function browse_note_B_Callback(hObject, eventdata, handles)
% hObject    handle to browse_note_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, filePath] = uigetfile({'*.txt','text files (*.txt)'; '*.*',  'All Files (*.*)'}, 'Sleep Notes File');
set(handles.twinNotesS, 'String', fullfile(filePath,fileName));

%% Menu Items

% --------------------------------------------------------------------
function start_m_Callback(hObject, eventdata, handles)
% hObject    handle to start_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function chan_m_Callback(hObject, eventdata, handles)
% hObject    handle to chan_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function montage_m_Callback(hObject, eventdata, handles)
% hObject    handle to montage_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function sleepStats_m_Callback(hObject, eventdata, handles)
% hObject    handle to sleepStats_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function mark_m_Callback(hObject, eventdata, handles)
% hObject    handle to mark_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function starMark_m_Callback(hObject, eventdata, handles)
% hObject    handle to starMark_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
mark_t_ClickedCallback(handles.mark_t, eventdata, handles)


% --------------------------------------------------------------------
function clearEvents_m_Callback(hObject, eventdata, handles)
% hObject    handle to clearEvents_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in eventClear.
out = inputdlg('Enter event name to clear (e.g. REM):');
if(~isempty(out))
    event = out{1};
else
    event = '';
end

if(isfield(handles.stageData, 'events') && ~isempty(event))
    if(isfield(handles.stageData.events, event))
        handles.stageData.events = rmfield(handles.stageData.events, event);
        guidata(hObject, handles)
        curX = xlim(handles.axes1);
        range = curX(1):curX(2);
        handles = plotSleepData(handles, range);
        
        if(length(fields(handles.stageData)) >= 9)
            stageData = handles.stageData;
            %save(get(handles.stageFileIN, 'String'), 'stageData');
        end
    else
        errordlg(['There are no evets called: ', event]);
    end
else
    errordlg('There are no events in this dataset');
end



% --------------------------------------------------------------------
function runStats_m_Callback(hObject, eventdata, handles)
% hObject    handle to runStats_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in statsB.if(~isempty(out))
sleepStats_woInput(handles.stageData, get(handles.stageFileIN, {'String'}), handles.EEG);

% --------------------------------------------------------------------
function hideChan_m_Callback(hObject, eventdata, handles)
% hObject    handle to hideChan_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = inputdlg('Enter the channel to hide (e.g. EMG1):');
if(~isempty(out))
    chan = out{1};
    handles.hideChans{end + 1} = chan;
    guidata(hObject, handles)
    curX = xlim(handles.axes1);
    range = curX(1):curX(2);
    handles = plotSleepData(handles, range);
end


% --------------------------------------------------------------------
function showChan_m_Callback(hObject, eventdata, handles)
% hObject    handle to showChan_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = inputdlg('Enter the channel to show (e.g. EMG1):');
if(~isempty(out))
    chan = out{1};
    handles.hideChans(find(strcmp(handles.hideChans, chan))) = [];
    guidata(hObject, handles)
    curX = xlim(handles.axes1);
    range = curX(1):curX(2);
    handles = plotSleepData(handles, range);
end

% --------------------------------------------------------------------
function nweData_m_Callback(hObject, eventdata, handles)
% hObject    handle to nweData_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.setupPan, 'Visible', 'on')

% --------------------------------------------------------------------
function compScores_m_Callback(hObject, eventdata, handles)
% hObject    handle to compScores_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --------------------------------------------------------------------
function loadComp_Callback(hObject, eventdata, handles)
% hObject    handle to loadComp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fileName, filePath] = uigetfile({'*.mat','MAT-files (*.mat)'; '*.*',  'All Files (*.*)'}, 'Sleep Stage File for Comparison');
compStage = load(fullfile(filePath,fileName));
compStages = compStage.stageData.stages;
if(length(compStages) < length(handles.stageData.stages))
    tmp = ones(size(handles.stageData.stages))*7;
    tmp(1:length(compStages)) = compStages;
    compStages = tmp;
elseif(length(compStages) > length(handles.stageData.stages))
    compStages = compStages(1:length(handles.stageData.stages));
end
handles.compStage = compStages;
handles.second_stageData = compStage;
handles.showComp = 0;
guidata(hObject, handles)

% --------------------------------------------------------------------
function showCompHyp_m_Callback(hObject, eventdata, handles)
% hObject    handle to showCompHyp_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if(~isfield(handles, 'compStage'))
    loadComp_Callback(handles.loadComp, eventData, handles);
end
handles.showComp = 1;
guidata(hObject, handles)

% --------------------------------------------------------------------
function hideCompHyp_m_Callback(hObject, eventdata, handles)
% hObject    handle to hideCompHyp_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.showComp = 0;
guidata(hObject, handles)

%% Tool Bar Functions
% --------------------------------------------------------------------
function lightsOff_t_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to lightsOff_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winSize = str2num(get(handles.winIN, 'String'));
srate = handles.EEG.srate;
pt = etime(datevec(handles.stageData.lightsOFF), datevec(handles.stageData.recStart))/60;
ptX = floor(pt(1)*(60/winSize))*winSize*srate;
jumpto(handles, ptX)

% --------------------------------------------------------------------
function lightsOn_t_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to lightsOn_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
winSize = str2num(get(handles.winIN, 'String'));
srate = handles.EEG.srate;
pt = etime(datevec(handles.stageData.lightsON), datevec(handles.stageData.recStart))/60;
ptX = floor(pt(1)*(60/winSize))*winSize*srate;
jumpto(handles, ptX)

% --------------------------------------------------------------------
function jumpTo_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to jumpTo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
out = inputdlg('Enter Epoch #:');
if(~isempty(out))
    epoch = out{1};
else
    epoch = '';
end
if(~isempty(epoch))
    winSize = str2num(get(handles.winIN, 'String'));
    srate = handles.EEG.srate;
    jumpto(handles, (str2double(epoch) - 1)*winSize*srate)
end


% --------------------------------------------------------------------
function notes_t_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to notes_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if(strcmp(get(handles.notePan, 'Visible'),'on'))
    set(handles.notePan, 'Visible', 'off')
else
    set(handles.notePan, 'Visible', 'on')
end


% --------------------------------------------------------------------
function mark_t_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to mark_t (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- Executes on button press in markB.
if(strcmp(get(handles.slopeB, 'Enable'), 'on'))
%   set(handles.markStr, 'Enable', 'off')
%    set(handles.setMark, 'Enable', 'off')
%    set(handles.delMark, 'Enable', 'off')
    set(handles.slopeB, 'Enable', 'off')
else
 %   set(handles.markStr, 'Enable', 'on')
 %   set(handles.setMark, 'Enable', 'on')
 %  set(handles.delMark, 'Enable', 'on')
    set(handles.slopeB, 'Enable', 'on')
end

datacursormode('toggle');
handles.cursor=datacursormode(gcf);
set(handles.cursor, 'UpdateFcn', {@cursorInfoUpdate,handles})
guidata(hObject, handles);


% --- Executes on selection change in plotSleepIN.
function plotSleepIN_Callback(hObject, eventdata, handles)
% hObject    handle to plotSleepIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns plotSleepIN contents as cell array
%        contents{get(hObject,'Value')} returns selected item from plotSleepIN
curX = xlim(handles.axes1);
%range = curX(1):curX(2);
range=[curX(1):1:((curX+handles.stageData.win*handles.EEG.srate)-1)];

plotFCN = get(handles.plotSleepIN, 'String');
boxInd = get(handles.plotSleepIN, 'Value');
    
eval(['mont = ',plotFCN{boxInd}, '(handles);']);

if length(intersect({handles.EEG.chanlocs.labels}, mont.electrodes)) == length(mont.electrodes)
    handles.CurrMontage = mont;
    handles = plotSleepData(handles, range);
    guidata(hObject, handles);
else
    waitfor(msgbox('Montage is incompatible. Try again'));
end


% --- Executes during object creation, after setting all properties.
function plotSleepIN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to plotSleepIN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function info_m_Callback(hObject, eventdata, handles)
% hObject    handle to info_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function aInfo_m_Callback(hObject, eventdata, handles)
% hObject    handle to aInfo_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg = sprintf(['Program Authors: Jared M. Saletin, PhD & Stephanie M. Greer, PhD \n\n',...
    'In association with:\n\n', ...
    'Sleep for Science Research Laboratory (PI: Mary A. Carskadon, PhD)\n', ...
    'Department of Psychiatry and Human Behavior\n', ...
    'Alpert Medical School of Brown University\n\n', ...
    'Sleep and Neuroimaging Laboratory (PI: Matthew P. Walker, PhD)\n', ...
    'Helen Wills Neuroscience Institute\n', ...
    'Department of Psychology \n', ...
    'University of California Berkeley\n\n', ...
    'Contact: jared_saletin@brown.edu\n', ...
    'https://sourceforge.net/projects/sleepsmg']);
msgbox(msg, 'Author Info');


% --------------------------------------------------------------------
function hKeysInfo_m_Callback(hObject, eventdata, handles)
% hObject    handle to hKeysInfo_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg = sprintf(['To use keyborad for scoring first click anywhere on the window that does not contain an object.\n\n',...
    'Short Cuts:\n', ...
    '0 - Stage Wake\n', ...
    '1 - Stage 1 \n', ...
    '2 - Stage 2\n', ...
    '3 - Stage 3\n', ...
    '3 - Stage 4\n', ...
    '5 - Stage REM\n', ...
    '6 - Movement Time\n', ...
    '. - Mark epoch as anomolous/unscored\n', ...
    '7 - scroll to the left\n', ...
    '9 - scroll to the right\n\n', ...
    'CTRL-o - Import/Open New Dataset\n', ...
    'CTRL-s - Save Dataset\n', ...
    'CTRL-w - Close Húmë\n', ...
    'CTRL-e - Toggle Event Mode On/Off\n', ...
    '*The keyboard short cuts will not work when event marking mode is turned on.']);
msgbox(msg, 'Hot Keys');


% --------------------------------------------------------------------
function saveData_m_Callback(hObject, eventdata, handles)
% hObject    handle to saveData_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
stageData=handles.stageData;
save(get(handles.stageFileIN, 'String'), 'stageData');
msgbox('Save Complete');


% --------------------------------------------------------------------
function editMontage_Callback(hObject, eventdata, handles)
% hObject    handle to editMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if isfield(handles,'EEG')
    [output mont] = sleepMontageEditor(handles);
    
    handles.CurrMontage.colors = mont.colors;
    handles.CurrMontage.electrodes = mont.electrodes;
    handles.CurrMontage.bigGridMat = mont.bigGridMat;
    handles.CurrMontage.hideChans = mont.hideChans;
    handles.CurrMontage.scaleChans = mont.scaleChans;
    handles.CurrMontage.scale = mont.scale;
    handles.CurrMontage.o2satChs = mont.o2satChs;
    handles.CurrMontage.negChans = mont.negChans;
    sleepPath = which('hume');
    montageNames = dir(fullfile(fileparts(sleepPath), 'montages'));
    montages = [];
    for i = 1:length(montageNames)
        if(strfind(montageNames(i).name, '_Montage.m'))
            montages{length(montages) + 1} = montageNames(i).name(1:(end - 2));
        end
    end
    set(handles.plotSleepIN, 'String', montages)

    curX = xlim(handles.axes1);
    range = curX(1):curX(2);
    
    handles = plotSleepData(handles, range);
    guidata(hObject, handles);
    
else
    errordlg('No EEG file loaded, please load data and re-open Montage Editor', 'Húmë Montage Editor');
    
end



% --------------------------------------------------------------------
function runStatsWOinput_2_Callback(hObject, eventdata, handles)
% hObject    handle to runStatsWOinput_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sleepStats;


% --------------------------------------------------------------------
function createMontage_Callback(hObject, eventdata, handles)
% hObject    handle to createMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sleepMontageCreator;


% --------------------------------------------------------------------
function runReliability_Callback(hObject, eventdata, handles)
% hObject    handle to runReliability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sleepReliability;


% --------------------------------------------------------------------
function editMontage_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to editMontage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
editMontage_Callback(hObject,eventdata, handles);


% --------------------------------------------------------------------
function runStats_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to runStats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
disp 'hi';
sleepStats_woInput(handles.stageData, get(handles.stageFileIN, {'String'}),handles.EEG);


% --------------------------------------------------------------------
function saveData_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to saveData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
saveData_m_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function openData_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to openData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if strcmp(get(handles.setupPan,'Visible'),'on')
    set(handles.setupPan,'Visible','off');
else
set(handles.setupPan, 'Visible', 'on')
end


% --------------------------------------------------------------------
function closeHume_Callback(hObject, eventdata, handles)
% hObject    handle to closeHume (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
humeWindow_CloseRequestFcn(hObject, [], handles);


% --------------------------------------------------------------------
function uploadServer_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to uploadServer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
sleepStatsDBCommit;


% --------------------------------------------------------------------
function upload_Callback(hObject, eventdata, handles)
% hObject    handle to upload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(getappdata(0,'Conn'))
    if isopen(getappdata(0,'Conn'))
        
        c = getappdata(0,'Conn');
        if strcmp(c.Driver, 'org.sqlite.JDBC')
            sleepDBUpload_sqlite;
        else
            sleepDBUpload;
        end
    else
        signOut_Callback([],[],handles);
    end
else
    signOut_Callback([],[],handles);
end


% --------------------------------------------------------------------
function Untitled_3_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_2_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Untitled_4_Callback(hObject, eventdata, handles)
% hObject    handle to Untitled_4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function sqlLogin_Callback(hObject, eventdata, handles)
% hObject    handle to sqlLogin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(sleepDBConnect);
if ~isempty(getappdata(0,'Conn'))
    if isopen(getappdata(0,'Conn'))
        
        % Activate Buttons
        set(handles.signOut,'Enable','on');
        set(handles.upload,'Enable','on');
        set(handles.genTable,'Enable','on');         
        
        % Hide Login
        set(handles.sqlLogin,'Enable','off');
        set(handles.sqliteLogin,'Enable','off');
    end
end
% --------------------------------------------------------------------
function signOut_Callback(hObject, eventdata, handles)
% hObject    handle to signOut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if ~isempty(getappdata(0,'Conn'))
    if isopen(getappdata(0,'Conn'))
        open = 1;
    else
        open = 0;
    end
else
    open = 0;
end

if open ==1
    
    close(getappdata(0,'Conn'));
    setappdata(0,'Conn',[]);
    set(handles.signOut,'Enable','off');
    set(handles.upload,'Enable','off');
    set(handles.genTable,'Enable','off');
    set(handles.sqlLogin,'Enable','on');
    set(handles.sqliteLogin,'Enable','on');
    msgbox('Server Disconnected!');
    
else
    set(handles.signOut,'Enable','off');
    set(handles.upload,'Enable','off');
    set(handles.genTable,'Enable','off');
    set(handles.sqlLogin,'Enable','on');
    set(handles.sqliteLogin,'Enable','on');
    msgbox('Server Already Closed!');
end



% --------------------------------------------------------------------
function genTable_Callback(hObject, eventdata, handles)
% hObject    handle to genTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
c = getappdata(0,'Conn');
if strcmp(c.Driver, 'org.sqlite.JDBC')
    sleepStatsDBReport_sqlite(getappdata(0,'Conn'), handles);
else
    sleepStatsDBReport(getappdata(0,'Conn'), handles);
end

% --- Executes when user attempts to close humeWindow.
function humeWindow_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to humeWindow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: delete(hObject) closes the figure
button = questdlg('Are you sure you want to quit Húmë?','Quit Húmë?','Yes','No','Yes');
if strcmp(button,'Yes')
    signOut_Callback(hObject,[],handles);
    closereq;
end

% --- Executes on button press in Artifact.
function Artifact_Callback(hObject, eventdata, handles)
% hObject    handle to Artifact (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Value = handles.currentArtifact;
if Value
    
    curWin = xlim(handles.axes1);
    ep = floor(curWin(2)/(handles.stageData.win*handles.EEG.srate));
    if isfield(handles.stageData, 'MarkedEvents')
       handles.stageData.MarkedEvents(find(cell2mat(handles.stageData.MarkedEvents(:,3))==ep),:) =[];
    end
 %   set(hObject,'Value',0)
    handles.currentArtifact = 0;
    set(handles.axes1,'Color',[1 1 1])
    set(handles.Artifact,'BackgroundColor',[1 1 1]);
    curX = xlim(handles.axes1);
    range = curX(1):curX(2);
    handles = plotSleepData(handles, range);
else
  %  set(hObject,'Value',1)
    handles.currentArtifact = 1;
    set(handles.axes1,'Color',[1 .95 .95])
    set(handles.Artifact,'BackgroundColor',[1 .95 .95]);
    curWin = xlim(handles.axes1);
    ep = floor(curWin(2)/(handles.stageData.win*handles.EEG.srate));
    eventData = {'[0]', curWin(1), ep, NaN};
    
    if ~isfield(handles.stageData, 'MarkedEvents')
        handles.stageData.MarkedEvents = eventData;
    else
        handles.stageData.MarkedEvents = [handles.stageData.MarkedEvents; eventData];
    end
    curX = xlim(handles.axes1);
    range = curX(1):curX(2);
    handles = plotSleepData(handles, range);
end
guidata(hObject,handles);
% Hint: get(hObject,'Value') returns toggle state of Artifact


% --------------------------------------------------------------------
function eventCodes_m_Callback(hObject, eventdata, handles)
% hObject    handle to eventCodes_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
msg = 'hi';
msgbox(msg, 'Hot Keys');

function eventMark(hObject, eventData, handles)

    [x y] = ginput(2);
    y = round(y(1)/150);
    
    % check and see if draggable events exist
    if isfield(handles.stageData,'rectEvents')
     
    
    

    % check if an event ends on the last page right before (within 1
    % seconds)
    %rectangle('Position', [x(1) y(1)*150-75 x(2)-x(1) 150],'FaceColor', [1 .5 .3, .2]);
    timesToCheck = [x(1) - 1*handles.EEG.srate x(1)];
    evInRange=find( ...
               and(...
                    and(...
                        and([handles.stageData.rectEvents{:,3}] > timesToCheck(1), [handles.stageData.rectEvents{:,3}] < timesToCheck(2)),...
                        strcmp(handles.stageData.rectEvents(:,5)',handles.EventType.String{handles.EventType.Value})...
                    ),...
                   strcmp(handles.CurrMontage.electrodes(y(1)), handles.stageData.rectEvents(:,1)))  ...
                );    
            
    else
        evInRange = [];
    end
    
    if ~isempty(evInRange) 
        % If there are events in range, check to merge them.
        if length(evInRange)>1
            % there are more than one events and I don't know what to do
            % yet
            return
        else
            % Ask to combine events
            opts.Default = 'No';
            answer = questdlg({['A ',handles.EventType.String{handles.EventType.Value},' ends within 1s of this event.'],['Do you want to combine them?']},...
                'Combine Events',...
                'Yes','No',opts.Default);
            if strcmp(answer,'Yes')
                % replace start time with event being merged
                x(1) = handles.stageData.rectEvents{evInRange, 2};
                % delete event being merged
                handles.stageData.rectEvents(evInRange, :) = [];
            end
        end
    end
    
    if ~isfield(handles.stageData,'rectEvents')
        handles.stageData.rectEvents = {handles.CurrMontage.electrodes{y(1)} x(1)./handles.EEG.srate x(2)./handles.EEG.srate ceil(x(1)/handles.EEG.srate/handles.stageData.win) handles.EventType.String{handles.EventType.Value} [] 0};
    elseif isempty(handles.stageData.rectEvents)
        handles.stageData.rectEvents = {handles.CurrMontage.electrodes{y(1)} x(1)./handles.EEG.srate x(2)./handles.EEG.srate ceil(x(1)/handles.EEG.srate/handles.stageData.win) handles.EventType.String{handles.EventType.Value} [] 0};
    else
        handles.stageData.rectEvents(end+1,:) = {handles.CurrMontage.electrodes{y(1)} x(1)./handles.EEG.srate x(2)./handles.EEG.srate ceil(x(1)/handles.EEG.srate/handles.stageData.win) handles.EventType.String{handles.EventType.Value} [] 0};
    end
    

curX = xlim(handles.axes1);
range = curX(1):curX(2);
handles = plotSleepData(handles, range);
guidata(hObject, handles);

function eventRemove(hObject, eventdata,handles)
[x y] = ginput(1);
y = round(y(1)/150);
indx = find( ...
            and(ismember(handles.stageData.rectEvents(:,1), handles.CurrMontage.electrodes{y})' , ...         %channel
            and([handles.stageData.rectEvents{:,2}].*handles.EEG.srate<x, [handles.stageData.rectEvents{:,3}].*handles.EEG.srate>x)) ...% time
        ); % time
% IF A DETECTED EVENT DELETE ALL
detectedYN = handles.stageData.rectEvents{indx, 6};
if detectedYN
 answer = questdlg({'This is an automated event. Do you want to delete all events of this type?'},...
                ['Confirm ''', handles.stageData.rectEvents{indx,5},''' deletion?'],...
                'Delete all','Delete selected','Delete none', []);
            if strcmp(answer,'Delete all')
                handles.stageData.rectEvents(ismember(handles.stageData.rectEvents(:,5), handles.stageData.rectEvents(indx,5)), :) = []; 
            elseif strcmp(answer,'Delete selected')
                handles.stageData.rectEvents(indx,:)=[];
            end
else
    handles.stageData.rectEvents(indx,:)=[];
end

%handles.stageData.rectEvents(indx,:)=[];
curX = xlim(handles.axes1);
range = curX(1):curX(2);
handles = plotSleepData(handles, range);
guidata(hObject,handles);


% --- Executes on selection change in EventType.
function EventType_Callback(hObject, eventdata, handles)
% hObject    handle to EventType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns EventType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from EventType


% --- Executes during object creation, after setting all properties.
function EventType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to EventType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --------------------------------------------------------------------
function oscillationDetection_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to oscillationDetection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[output] = sleepDetectOscillations(handles.EEG.chanlocs);

%eventsout = SWSpiCoupling(handles.stageData, handles.EEG, 'F3', 'Slow Wave (Riedner/Massimini)F3)'edit , 'Sleep Spindle (Ferrarelli/Warby F3)');

% clear old detections
if isfield(handles.stageData,'rectEvents')
    if ~isempty(handles.stageData.rectEvents)
    handles.stageData.rectEvents(and( strcmp(output.type, handles.stageData.rectEvents(:,5)), strcmp(output.ch, handles.stageData.rectEvents(:,1))), :) = [];
    end
end


eval(['eventsout = ', output.functionCall]);

if ~isfield(handles.stageData,'rectEvents')
    handles.stageData.rectEvents = eventsout;
elseif isempty(handles.stageData.rectEvents)
    handles.stageData.rectEvents = eventsout;
else
    handles.stageData.rectEvents = [handles.stageData.rectEvents; eventsout];
end
curX = xlim(handles.axes1);
range = curX(1):curX(2);

handles = plotSleepData(handles, range);
guidata(hObject,handles);


% --------------------------------------------------------------------
function sqliteLogin_Callback(hObject, eventdata, handles)
% hObject    handle to sqliteLogin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
waitfor(sleepDBLocal);

if ~isempty(getappdata(0,'Conn'))
    if isopen(getappdata(0,'Conn'))
        
        % Activate Buttons
        set(handles.signOut,'Enable','on');
        set(handles.upload,'Enable','on');
        set(handles.genTable,'Enable','on');
        
        % Hide Login
        set(handles.sqlLogin,'Enable','off');
        set(handles.sqliteLogin,'Enable','off');
    end
end


% --------------------------------------------------------------------
function showEvents_ClickedCallback(hObject, eventdata, handles)
% hObject    handle to showEvents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
state = get(handles.showEvents,'State');
switch state
    case 'on'
        handles.plotEvents = 1;
    case 'off'
        handles.plotEvents = 0;
end
curX = xlim(handles.axes1);
range = curX(1):curX(2);
handles = plotSleepData(handles, range);
guidata(hObject,handles);


% --------------------------------------------------------------------
function detectOscillations_Callback(hObject, eventdata, handles)
% hObject    handle to detectOscillations (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
oscillationDetection_ClickedCallback(hObject, [], handles);

% --------------------------------------------------------------------
function oscillationReport_Callback(hObject, eventdata, handles)
% hObject    handle to oscillationReport (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
output = sleepOscillationReport(handles.stageData.rectEvents);
eval(output);

