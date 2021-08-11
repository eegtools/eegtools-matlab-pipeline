%% EEG = proj_eeglab_subject_preprocessing(project, varargin)
%
%% This script shows how to run the Spindler analysis for a data collection
%
% You must set up the following information (see examples below)
%   dataDir         path of directory containing EEG .set files to analyze
%   eventDir        directory of labeled event files
%   resultsDir      directory that Spindler uses to write its output
%   imageDir        directory that Spindler users to save images
%   summaryFile     full path name of the file containing the summary analysis
%   channelLabels   cell array containing possible channel labels
%                      (Spindler uses the first label that matches one in EEG)
%   paramsInit      structure containing the parameter values
%                   (if an empty structure, Spindler uses defaults)
%
% Spindler uses the input to run a batch analysis. If eventDir is not empty,
% Spindler runs performance comparisons, provided it can match file names for
% files in eventDir with those in dataDir.  Ideally, the event file names
% should have the data file names as prefixes, although Spindler tries more
% complicated matching strategies as well.  Event files contain "ground truth"
% in text files with two columns containing the start and end times in seconds.
%

%
%%
function project = proj_eeglab_subject_detect_spindle_spindler(project, varargin)


list_select_subjects    = project.subjects.list;
get_filename_step       = 'output_import_data';
custom_suffix           = '';
custom_input_folder     = '';

for par=1:2:length(varargin)
    switch varargin{par}
        case {  ...
                'list_select_subjects', ...
                'get_filename_step',    ...
                'custom_input_folder',  ...
                'custom_suffix' ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end

if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
numsubj = length(list_select_subjects);
% -------------------------------------------------------------------------------------------------------------------------------------

%% nota introdurre 2 analisi una automatica, l'altra basata sugli spindle identificati dall'operatore.

for subj=1:numsubj
    
    subj_name               = list_select_subjects{subj};
    input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    disp(input_file_name);
    
    
    %% Get the data and event file names and check that we have the same number
    %     dataFiles = getFileListWithExt('FILES', dataDir, '.set');
    
    if exist(input_file_name)
        dataFiles                     = {input_file_name};
    else
        disp('no such file!');
        return
    end
    
    
    % dir with files procuced by spindler
    spindlerdir = fullfile(project.paths.project, 'spindler');
    if not(exist(spindlerdir))
        mkdir(spindlerdir);
    end
    
    disp(spindlerdir);
    % spindler toolbox dir
    project.paths.plugin.spindler              = fullfile(project.paths.plugins_root, 'EEG-Spindles', 'spindler');
    addpath(genpath(project.paths.plugin.spindler))
    
    
    stageDir = fullfile(spindlerdir,'stageDir');
    if not(exist(stageDir))
        mkdir(stageDir);
    end
    
    resultsDir = fullfile(spindlerdir,'resultsDir');
    if not(exist(resultsDir))
        mkdir(resultsDir);
    end
    
    eventDir = fullfile(spindlerdir,'eventDir');
     if not(exist(eventDir))
        mkdir(eventDir);
     end
    
    imageDir = fullfile(spindlerdir,'imageDir');
    if not(exist(imageDir))
        mkdir(imageDir);
    end
    
    channelLabels_list = project.sleep.spindler.channelLabels;
    eventLabels_list = project.sleep.spindler.eventLabels;
    tot_cl = length(channelLabels_list);
    
    paramsInit = struct();
    paramsInit.spindleFrequencyRange = project.sleep.spindler.paramsInit.spindleFrequencyRange;
    % addpath(genpath('C:\work\work-matlab\matlab_toolbox\EEG-Spindles\spindler'))
    %  runSpindler
    
    
    
    %% runSpindler part
    
    %% Common initialization
    paramsInit.figureClose = true;
    paramsInit.figureFormats = {'png', 'fig'};
    paramsInit.srateTarget = 0;
    
    
    
    %% Create the output directory if it doesn't exist
    if ~isempty(resultsDir) && ~exist(resultsDir, 'dir')
        fprintf('Creating results directory %s \n', resultsDir);
        mkdir(resultsDir);
    end
    if ~isempty(imageDir) && ~exist(imageDir, 'dir')
        fprintf('Creating image directory %s \n', imageDir);
        mkdir(imageDir);
    end
    
    
    %% copy forked functions into hume directory (to recover, remove and git pull)
    getChannelData_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['getChannelData.m']);
    getChannelDatadir_spindler = fullfile(project.paths.plugin.spindler, 'utilities');
    copyfile( getChannelData_m,getChannelDatadir_spindler);
    
%     C:\work\work-matlab\matlab_toolbox\EEG-Spindles\spindler\utilities
    
    %% Process the data
    for k = 1:length(dataFiles)
       
        for ncl =1:tot_cl
            
            channelLabels = channelLabels_list(ncl);
            eventLabels = eventLabels_list(ncl);
            disp(['Processing Event:',char(eventLabels),' on Channel:',char(channelLabels)]);
           
            imageDir = fullfile(spindlerdir,'imageDir',[char(eventLabels),'_',char(channelLabels)]);
            if not(exist(imageDir))
                mkdir(imageDir);
            end
            
            %% Read in the EEG and find the correct channel number
            params = paramsInit;
            [~, theName, ~] = fileparts(dataFiles{k});
            params.name = theName;
            [data, srateOriginal, srate, channelNumber, channelLabel] = ...
                getChannelData(dataFiles{k}, channelLabels, params.srateTarget);
            if isempty(data)
                warning('No data found for %s\n', dataFiles{k});
                continue;
            end
            
            
            %%%%%%%%%%%% do unsupervised spindle analysis
            imageDir = fullfile(spindlerdir,'imageDir',[char(channelLabels),'_','auto']);
            if not(exist(imageDir))
                mkdir(imageDir);
            end
            %% Read events and stages if available
            expertEvents = readEvents(eventDir, '');
            stageEvents = readEvents(stageDir, '');
            
            %% Use the longest stretch in the stage events
            [data, startFrame, endFrame, expertEvents] = ...
                getMaxStagedData(data, srate, stageEvents, expertEvents);
            
            %% Call Spindler to find the spindles and metrics
            [spindles, additionalInfo, params] =  ...
                spindler(data, srate, expertEvents, imageDir, params);
            additionalInfo.srate = srate;
            additionalInfo.srateOriginal = srate;
            additionalInfo.channelNumber = channelNumber;
            additionalInfo.channelLabel = channelLabel;
            additionalInfo.startFrame = startFrame;
            additionalInfo.endFrame = endFrame;
            additionalInfo.stageEvents = stageEvents;
            atomInd = additionalInfo.parameterCurves.bestEligibleAtomInd;
            threshInd = additionalInfo.parameterCurves.bestEligibleThresholdInd;
            if isempty(atomInd) || isempty(threshInd)
                events = nan;
                additionalInfo.atomsPerSecond = nan;
                additionalInfo.numberAtoms = nan;
                additionalInfo.threshold = nan;
                additionalInfo.numberSpindles = nan;
                additionalInfo.spindleTime = nan;
            else
                theseSpindles = spindles(atomInd, threshInd);
                events = theseSpindles.events;
                additionalInfo.atomsPerSecond = theseSpindles.atomsPerSecond;
                additionalInfo.numberAtoms = theseSpindles.numberAtoms;
                additionalInfo.threshold = theseSpindles.threshold;
                additionalInfo.numberSpindles = theseSpindles.numberSpindles;
                additionalInfo.spindleTime = theseSpindles.spindleTime;
            end
            theFile = [resultsDir filesep theName,'_',char(channelLabels),'_','auto','_','.mat'];
            save(theFile, 'events', 'expertEvents', 'params', ...
                'additionalInfo', 'spindles', '-v7.3');
            
            
            
            
            
            
            %%%%%%%%%%%% do supervised spindle analysis
            imageDir = fullfile(spindlerdir,'imageDir',[char(eventLabels),'_',char(channelLabels)]);
            if not(exist(imageDir))
                mkdir(imageDir);
            end
            %% Read events and stages if available
            expertEvents = readEvents(eventDir, [theName,'_',char(eventLabels),'_',char(channelLabels), '.mat']);
            stageEvents = readEvents(stageDir, [theName,'_stad', '.mat']);
            
            if (isempty(expertEvents))
                disp(['Error in loading user events from', fullfile(eventDir, [theName,'_',char(eventLabels),'_',char(channelLabels), '.mat'])]);
            else
                disp(['Correctly loading user events from', fullfile(eventDir, [theName,'_',char(eventLabels),'_',char(channelLabels), '.mat'])]);
            end
            
            
            if (isempty(expertEvents))
                disp(['Error in loading user sleep staging from', fullfile(stageDir, [theName,'_stad', '.mat'])]);
            else
                disp(['Correctly loading user sleep staging from', fullfile(stageDir, [theName,'_stad', '.mat'])]);
            end
            
            %% Use the longest stretch in the stage events
            [data, startFrame, endFrame, expertEvents] = ...
                getMaxStagedData(data, srate, stageEvents, expertEvents);
            
            %% Call Spindler to find the spindles and metrics
            [spindles, additionalInfo, params] =  ...
                spindler(data, srate, expertEvents, imageDir, params);
            additionalInfo.srate = srate;
            additionalInfo.srateOriginal = srate;
            additionalInfo.channelNumber = channelNumber;
            additionalInfo.channelLabel = channelLabel;
            additionalInfo.startFrame = startFrame;
            additionalInfo.endFrame = endFrame;
            additionalInfo.stageEvents = stageEvents;
            atomInd = additionalInfo.parameterCurves.bestEligibleAtomInd;
            threshInd = additionalInfo.parameterCurves.bestEligibleThresholdInd;
            if isempty(atomInd) || isempty(threshInd)
                events = nan;
                additionalInfo.atomsPerSecond = nan;
                additionalInfo.numberAtoms = nan;
                additionalInfo.threshold = nan;
                additionalInfo.numberSpindles = nan;
                additionalInfo.spindleTime = nan;
            else
                theseSpindles = spindles(atomInd, threshInd);
                events = theseSpindles.events;
                additionalInfo.atomsPerSecond = theseSpindles.atomsPerSecond;
                additionalInfo.numberAtoms = theseSpindles.numberAtoms;
                additionalInfo.threshold = theseSpindles.threshold;
                additionalInfo.numberSpindles = theseSpindles.numberSpindles;
                additionalInfo.spindleTime = theseSpindles.spindleTime;
            end
            theFile = [resultsDir filesep theName,'_',char(eventLabels),'_',char(channelLabels),'_','.mat'];
            save(theFile, 'events', 'expertEvents', 'params', ...
                'additionalInfo', 'spindles', '-v7.3');
        end
    end
    
end

