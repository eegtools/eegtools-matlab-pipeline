 %% project
%           A: start
%           B: paths

%           SUBJECT PROCESSING
%           C: task
%           D: import
%           E: eegdata    
%           F: preproc
%           G: epoching

%           H: subjects

%           GROUP PROCESSING
%           I: study
%           L: design
%           M: stats
%           N: postprocess
%           O: results_display
%           P: export
%           Q: clustering
%           R: brainstorm

% times are always defined in seconds and derived in ms 
% this file need the variable: project_folder
% 
% graphical information structure
% = struct('visible', 'on', 'type', 'label', 'default', '');
%
% TYPE:
% - label           read-only text
% - input text      free text, filled with keyboard
% - input_array     free array, type of array (numeric or cell) must be specified
% - combobox        value selected from a list
% - select listbox  values selected from a list
% - input listbox   values added with a button 'add' to a list..so edit and remove button should be also present
% - checkbox        values 'on' or 'off'
% - input datagrid (two dimensional cell array)
% 
% DEFAULT:
% - free string
% - cell array
% - 'selfvar'   take the values from the project variable (to be used with variable that display a precalculated variable)

%% ======================================================================================================
% A:    START
% ======================================================================================================
...project.research_group                           % A1: set in main: e.g.  PAP or MNI
...project.research_subgroup                        % A2: set in main: e.g.  PAP or MNI
...project.name                                     % A3: set in main : must correspond to 'project.paths.local_projects_data' subfolder name

projectgui.study_suffix                                = struct('visible', 'on', 'type', 'input', 'default', '');                % A4: sub name used to create a different STUDY name (fianl file will be called: [projectgui.name projectgui.study_suffix '.study'])
projectgui.analysis_name                               = struct('visible', 'on', 'type', 'input', 'default', '');    % A5: epoching output folder name, subfolder containing the condition files of the current analysis type

projectgui.do_source_analysis                          = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');                    % A6:  
projectgui.do_emg_analysis                             = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');                    % A7:
projectgui.do_cluster_analysis                         = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');                    % A8:

%% ======================================================================================================
% B:    PATHS  
% ======================================================================================================
% set by: main file
...projectgui.paths.projectguis_data_root                 % B1:   folder containing local RBCS projectguis root-folder,  set in main
...projectgui.paths.svn_scripts_root                   % B2:   folder containing local RBCS script root-folder,  set in main
...projectgui.paths.plugins_root                       % B3:   folder containing local MATLAB PLUGING root-folder, set in main

...projectgui.paths.script.common_scripts              % B4:
...projectgui.paths.script.eeg_tools                   % B5:
...projectgui.paths.script.projectgui                     % B6:

% set by define_paths_structure
...projectgui.paths.global_scripts                     % B7:
...projectgui.paths.global_spm_templates               % B8:

% set by: define_paths_structure
projectgui.paths.projectgui                             = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                        % B9:   folder containing data, epochs, results etc...(not scripts)
projectgui.paths.original_data                          = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                     % B10:  folder containing EEG raw data (BDF, vhdr, eeg, etc...)
projectgui.paths.input_epochs                           = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                      % B11:  folder containing EEGLAB EEG input epochs set files 
projectgui.paths.output_epochs                          = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                     % B12:  folder containing EEGLAB EEG output condition epochs set files
projectgui.paths.results                                = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                           % B13:  folder containing statistical results
projectgui.paths.emg_epochs                             = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                        % B14:  folder containing EEGLAB EMG epochs set files 
projectgui.paths.emg_epochs_mat                         = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                    % B15:  folder containing EMG data strucuture
projectgui.paths.tf                                     = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                                % B16:  folder containing 
projectgui.paths.cluster_projectguiion_erp              = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');            % B17:  folder containing 
projectgui.paths.batches                                = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                           % B18:  folder containing bash batches (usually for SPM analysis)
projectgui.paths.spmsources                             = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                        % B19:  folder containing sources images exported by brainstorm
projectgui.paths.spmstats                               = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                          % B20:  folder containing spm stat files
projectgui.paths.spm                                    = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                               % B21:  folder containing spm toolbox
projectgui.paths.eeglab                                 = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                            % B22:  folder containing eeglab toolbox
projectgui.paths.brainstorm                             = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                        % B23:  folder containing brainstorm toolbox

%% ======================================================================================================
% C:    TASK
% ======================================================================================================
projectgui.task.events.start_experiment_trigger_value  = struct('visible', 'on', 'type', 'input', 'default', '');    % C1:   signal experiment start
projectgui.task.events.pause_trigger_value             = struct('visible', 'on', 'type', 'input', 'default', '');    % C2:   start: pause, feedback and rest period
projectgui.task.events.resume_trigger_value            = struct('visible', 'on', 'type', 'input', 'default', '');    % C3:   end: pause, feedback and rest period
projectgui.task.events.end_experiment_trigger_value    = struct('visible', 'on', 'type', 'input', 'default', '');    % C4:   signal experiment end
projectgui.task.events.videoend_trigger_value          = struct('visible', 'on', 'type', 'input', 'default', '');
projectgui.task.events.question_trigger_value          = struct('visible', 'on', 'type', 'input', 'default', '');
projectgui.task.events.AOCS_audio_trigger_value        = struct('visible', 'on', 'type', 'input', 'default', '');
projectgui.task.events.AOIS_audio_trigger_value        = struct('visible', 'on', 'type', 'input', 'default', '');
projectgui.task.events.cross_trigger_value             = struct('visible', 'on', 'type', 'input', 'default', '');

%% ======================================================================================================
% D:    IMPORT
% ======================================================================================================
% input file name  = [original_data_prefix subj_name original_data_suffix . original_data_extension]
% output file name = [original_data_prefix subj_name original_data_suffix projectgui.import.output_suffix . set]

% input
projectgui.import.acquisition_system       = struct('visible', 'on', 'type', 'combobox', 'default', {'BIOSEMI', 'BRAINVISION', 'EDF'});                    % D1:   EEG hardware type: BIOSEMI | BRAINAMP
projectgui.import.original_data_extension  = 'bdf';                        % D2:   original data file extension BDF | vhdr
projectgui.import.original_data_folder     = struct('visible', 'on', 'type', 'input', 'default', '');            % D3:   original data file subfolder
projectgui.import.original_data_suffix     = struct('visible', 'on', 'type', 'input', 'default', '');                       % D4:   string after subject name in original EEG file name....often empty
projectgui.import.original_data_prefix     = struct('visible', 'on', 'type', 'input', 'default', '');                          % D5:   string before subject name in original EEG file name....often empty


% output
projectgui.import.output_folder            = projectgui.import.original_data_folder;  % D6:   string appended to fullfile(projectgui.paths.projectgui,'epochs', ...) , determining where to write imported file, by default coincides with original_data_folder
projectgui.import.output_suffix            = struct('visible', 'on', 'type', 'input', 'default', '');                           % D7:   string appended to input file name after importing original file
projectgui.import.emg_output_postfix       = struct('visible', 'on', 'type', 'input', 'default', '');                  			% D8:   string appended to input file name to EMG file

projectgui.import.reference_channels       = struct('visible', 'on', 'type', 'combobox', 'default', {[], 'CAR', 'sel elec'});                      % D9:   list of electrodes to be used as reference: []: no referencing, {'CAR'}: CAR ref, {'el1', 'el2'}: used those electrodes

% D10:   list of electrodes to transform
projectgui.import.ch2transform(1)          = struct('type', 'emg' , 'ch1', 28,'ch2', 32, 'new_label', 'bAPB');         ... emg bipolar                   
projectgui.import.ch2transform(2)          = struct('type', 'emg' , 'ch1', 43,'ch2', [], 'new_label', 'APB2');         ... emg monopolar
projectgui.import.ch2transform(3)          = struct('type', []    , 'ch1', 7,'ch2' , [], 'new_label', []);             ... discarded 
projectgui.import.ch2transform(4)          = struct('type', 'eog' , 'ch1', 53,'ch2', 54, 'new_label', 'hEOG');         ... eog bipolar
projectgui.import.ch2transform(5)          = struct('type', 'eog' , 'ch1', 55,'ch2', [], 'new_label', 'vEOG');         ... eog monopolar

% D11:  list of trigger marker to import. can be a cel array, or a string with these values: 'all', 'stimuli','responses'
projectgui.import.valid_marker             = {'S1' 'S2' 'S3' 'S4' 'S5' 'S 16' 'S 17' 'S 19' 'S 19' 'S 20' 'S 21' 'S 48' 'S 49' 'S 50' 'S 51' 'S 52' 'S 53' 'S 80' 'S 81' 'S 82' 'S 83' 'S 84' 'S 85' };  

%% ======================================================================================================
% E:    FINAL EEGDATA
% ======================================================================================================
projectgui.eegdata.nch                         = struct('visible', 'on', 'type', 'input', 'default', '');                           % E1:   final channels_number after electrode removal and polygraphic transformation
projectgui.eegdata.nch_eeg                     = struct('visible', 'on', 'type', 'input', 'default', '');                           % E2:   EEG channels_number
projectgui.eegdata.fs                          = struct('visible', 'on', 'type', 'input', 'default', '');                          % E3:   final sampling frequency in Hz, if original is higher, then downsample it during pre-processing
projectgui.eegdata.eeglab_channels_file_name   = 'standard-10-5-cap385.elp';   % E4:   universal channels file name containing the position of 385 channels
projectgui.eegdata.eeglab_channels_file_path   = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');                           % E5:   later set by define_paths
    
projectgui.eegdata.eeg_channels_list           = struct('visible', 'off', 'type', 'label', 'default', 'selfvar');  % E6:   list of EEG channels IDs

projectgui.eegdata.emg_channels_list           = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');
projectgui.eegdata.emg_channels_list_labels    = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');
projectgui.eegdata.eog_channels_list           = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');
projectgui.eegdata.eog_channels_list_labels    = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');

for ch_id=1:length(projectgui.import.ch2transform)
    ch = projectgui.import.ch2transform(ch_id);
    if ~isempty(ch.new_label)
        if strcmp(ch.type, 'emg')
            projectgui.eegdata.emg_channels_list           = [projectgui.eegdata.emg_channels_list (projectgui.eegdata.nch_eeg+ch_id)];
            projectgui.eegdata.emg_channels_list_labels    = [projectgui.eegdata.emg_channels_list_labels ch.new_label];
        elseif strcmp(ch.type, 'eog')
            projectgui.eegdata.eog_channels_list           = [projectgui.eegdata.eog_channels_list (projectgui.eegdata.nch_eeg+ch_id)];
            projectgui.eegdata.eog_channels_list_labels    = [projectgui.eegdata.eog_channels_list_labels ch.new_label];
        end
    end
end

projectgui.eegdata.no_eeg_channels_list = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');  % D10:  list of NO-EEG channels IDs

%% ======================================================================================================
% F:    PREPROCESSING
% ======================================================================================================
% input file name  = [original_data_prefix subj_name original_data_suffix projectgui.import.output_suffix . set]
% output file name = [original_data_prefix subj_name original_data_suffix projectgui.import.output_suffix . set]

% during import
projectgui.preproc.output_folder   = struct('visible', 'on', 'type', 'input', 'default', 'selfvar');     % F1:   string appended to fullfile(projectgui.paths.projectgui,'epochs', ...) , determining where to write imported file

% FILTER ALGORITHM (FOR ALL FILTERS IN THE projectgui)
% the _12 suffix indicate filetrs of EEGLab 12; the _13 suffix indicate filetrs of EEGLab 13
projectgui.preproc.filter_algorithm = struct('visible', 'on', 'type', 'combobox', 'default', {'pop_eegfiltnew_12', 'pop_basicfilter', ...
                                                                                              'causal_pop_iirfilt_12','noncausal_pop_iirfilt_12', ...
                                                                                              'causal_pop_eegfilt_12','noncausal_pop_eegfilt_12', ...
                                                                                              'causal_pop_eegfiltnew_13','noncausal_pop_eegfiltnew_13'});     % F2:   


% GLOBAL FILTER
projectgui.preproc.ff1_global    = struct('visible', 'on', 'type', 'input', 'default', 0.16);                       % F3:   lower frequency in Hz of the preliminar filtering applied during data import
projectgui.preproc.ff2_global    = struct('visible', 'on', 'type', 'input', 'default', 100);                        % F4:   higher frequency in Hz of the preliminar filtering applied during data import

% NOTCH
projectgui.preproc.do_notch      = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');                          % F5:   define if apply the notch filter at 50 Hz
projectgui.preproc.notch_fcenter = struct('visible', 'on', 'type', 'input', 'default', 50);                         % F6:   center frequency of the notch filter 50 Hz or 60 Hz
projectgui.preproc.notch_fspan   = struct('visible', 'on', 'type', 'input', 'default', 5);                          % F7:   halved frequency range of the notch filters  
projectgui.preproc.notch_remove_armonics = struct('visible', 'on', 'type', 'combobox', 'default', {'first', 'all'});            % F8:   'all' | 'first' reemove all or only the first harmonic(s) of the line current
% during pre-processing
%FURTHER EEG FILTER
projectgui.preproc.ff1_eeg     = struct('visible', 'on', 'type', 'input', 'default', 0.16);                         % F9:   lower frequency in Hz of the EEG filtering applied during preprocessing
projectgui.preproc.ff2_eeg     = struct('visible', 'on', 'type', 'input', 'default', 45);                           % F10:  higher frequency in Hz of the EEG filtering applied during preprocessing

%FURTHER EOG FILTER
projectgui.preproc.ff1_eog     = struct('visible', 'on', 'type', 'input', 'default', 0.16);                         % F11:  lower frequency in Hz of the EOG filtering applied during preprocessing
projectgui.preproc.ff2_eog     = struct('visible', 'on', 'type', 'input', 'default', 8);                            % F12:  higher frequency in Hz of the EEG filtering applied during preprocessing

%FURTHER EMG FILTER
projectgui.preproc.ff1_emg     = struct('visible', 'on', 'type', 'input', 'default', 5);                            % F13:   lower frequency in Hz of the EMG filtering applied during preprocessing
projectgui.preproc.ff2_emg     = struct('visible', 'on', 'type', 'input', 'default', 100);                          % F14:   higher frequency in Hz of the EMG filtering applied during preprocessing

% CALCULATE RT
projectgui.preproc.rt.eve1_type                = struct('visible', 'on', 'type', 'input', 'default', 'eve1_type');  % F15:
projectgui.preproc.rt.eve2_type                = struct('visible', 'on', 'type', 'input', 'default', 'eve2_type');  % F16:
projectgui.preproc.rt.allowed_tw_ms.min        = [];           % F17:
projectgui.preproc.rt.allowed_tw_ms.max        = [];           % F18:
projectgui.preproc.rt.output_folder            = [];           % F19:



%% ADD NEW MARKERS

% DEFINE MARKER LABELS
projectgui.preproc.marker_type.begin_trial     = struct('visible', 'on', 'type', 'input', 'default', 't1');
projectgui.preproc.marker_type.end_trial       = struct('visible', 'on', 'type', 'input', 'default', 't2');
projectgui.preproc.marker_type.begin_baseline  = struct('visible', 'on', 'type', 'input', 'default', 'b1');
projectgui.preproc.marker_type.end_baseline    = struct('visible', 'on', 'type', 'input', 'default', 'b2');

% INSERT BEGIN TRIAL MARKERS (only if both the target and the begin trial
% types are NOT empty)
projectgui.preproc.insert_begin_trial.target_event_types           = {'b1'};        % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the begin trial markers 
projectgui.preproc.insert_begin_trial.begin_trial_marker_type      = projectgui.preproc.marker_type.begin_trial;  % string denoting the type (i.e. label) of the new begin trial marker
projectgui.preproc.insert_begin_trial.delay.s                      = [0];                           % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new begin trial markers
                                                                                                %      with respect to the target events, if empty ([]) time shift = 0.

% INSERT END TRIAL MARKERS (only if both the target and the begin trial
% types are NOT empty)
projectgui.preproc.insert_end_trial.target_event_types             = {'b1'};        % string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the end trial markers 
projectgui.preproc.insert_end_trial.end_trial_marker_type          = projectgui.preproc.marker_type.end_trial;    % string denoting the type (i.e. label) of the new end trial marker
projectgui.preproc.insert_end_trial.delay.s                        = [2.5];                           % time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new end trial markers
   

% INSERT BEGIN BASELINE MARKERS (projectgui.epoching.baseline_replace.baseline_begin_marker)
projectgui.epoching.baseline_mark.baseline_begin_target_marker             = {'S 20','S 22','S 24','S 26'};                % a target event for placing the baseline markers: baseline begin marker will be placed at the target marker with a selected delay.
projectgui.epoching.baseline_mark.baseline_begin_target_marker_delay.s     = struct('visible', 'on', 'type', 'input', 'default', 0);                                         % the delay (in seconds) between the target marker and the begin baseline marker to be placed: 
                                                                                                                        % >0 means that baseline begin FOLLOWS the target, 
                                                                                                                        % =0 means that baseline begin IS AT THE SAME TIME the target, 
                                                                                                                        % <0 means that baseline begin ANTICIPATES the target.
                                                                                                                        % IMPOTANT NOTE: The latency information is displayed in seconds for continuous data, 
                                                                                                                        % or in milliseconds relative to the epoch's time-locking event for epoched data. 
                                                                                                                        % As we will see in the event scripting section, 
                                                                                                                        % the latency information is stored internally in data samples (points or EEGLAB 'pnts') 
                                                                                                                        % relative to the beginning of the continuous data matrix (EEG.data). 

% INSERT END BASELINE MARKERS (projectgui.epoching.baseline_replace.baseline_end_marker)                                                                                                                        
projectgui.epoching.baseline_mark.baseline_end_target_marker               = {'S 20','S 22','S 24','S 26'};                % a target event for placing the baseline markers: baseline begin marker will be placed at the target marker with a selected delay.
projectgui.epoching.baseline_mark.baseline_end_target_marker_delay.s       = struct('visible', 'on', 'type', 'input', 'default', 0);                                            % the delay (in seconds) between the target marker and the begin baseline marker to be placed: 
                                                                                                                        % >0 means that baseline begin FOLLOWS the target, 
                                                                                                                        % =0 means that baseline begin IS AT THE SAME TIME the target, 
                                                                                                                        % <0 means that baseline begin ANTICIPATES the target.
                                                                                                                        % IMPOTANT NOTE: The latency information is displayed in seconds for continuous data, 
                                                                                                                        % or in milliseconds relative to the epoch's time-locking event for epoched data. 
                                                                                                                        % As we will see in the event scripting section, 
                                                                                                                        % the latency information is stored internally in data samples (points or EEGLAB 'pnts') 
                                                                                                                        % relative to the beginning of the continuous data matrix (EEG.data). 
                                                                                                
% INSERT BLOCK MARKERS (only if
% projectgui.preproc.insert_end_trial.end_trial_marker_type is non empty)
projectgui.preproc.insert_block.trials_per_block                           = struct('visible', 'on', 'type', 'input', 'default', 40);              % number denoting the number of trials per block  
                      
% UNIFORM MONTAGES
projectgui.preproc.montage_list = {...
                                {'Fp1','Fp2','F7','F3','Fz','F4','F8','FC5','FC1','FC2','FC6','T7','C3','Cz',...
                                'C4','T8','TP9','CP5','CP1','CP2','CP6','TP10','P7','P3','Pz','P4','P8',...
                                'O1','Oz','O2','AF7','AF3','AF4','AF8','F5','F1','F2','F6','FT9','FT7',...
                                'FC3','FC4','FT8','FT10','C5','C1','C2','C6','TP7','CP3','CPz','CP4',...
                                'TP8','P5','P1','P2','P6','PO7','PO3','POz','PO4','PO8'};
                                
                                {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5',...
                                 'T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9','PO7','PO3','O1','Iz','Oz',...
                                 'POz','Pz','CPz','Fpz','Fp2','AF8','AF4','AFz','Fz','F2','F4','F6','F8','FT8','FC6',...
                                 'FC4','FC2','FCz','Cz','C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6',...
                                 'P8','P10','PO8','PO4','O2'}
};
                                                                                                
%% ======================================================================================================
% G:    EPOCHING
% =======================================================================================================
% input file name  = [original_data_prefix subj_name original_data_suffix projectgui.import.output_suffix epoching.input_suffix . set]
% output file name = [original_data_prefix subj_name original_data_suffix projectgui.import.output_suffix epoching.input_suffix '_' CONDXX. set]



%% replace baseline. 
% replace partially or totally the period before/after the experimental triggers   
% problem: when epoching, generally there is the need to do a baseline correction. however sometimes no part of the extracted epoch can be assumed as a good baseline.
% The standard STUDY pipeline does NOT allow to consider smoothly external baselines.
% Here is the possibility, for each trial, to replace part of the extracted epoch around each experimental event in the trial, by a segment (in the same trial or outside), 
% that it's known to be a 'good' baseline.
% The procedure has some requirements:
% 
% 1. have already marked in the recording events denoting begin/end of trial
%
% 2. have already marked in the recording events denoting begin/end of baseline
%
% NOTE that 1 and 2 can be switched in the analysis if you that the the 'good' baseline is at beginning of each trial (e.g. a pre-stimulus).
% in this case, you should mark the baselines (using as target events the stimuli) and then mark the trial, using as target for the beginnig of the
% trial the new baseline begin marker. Or, you can to both mark baseline and trial use the same stimuli marker as target events, giving the right delays.

projectgui.epoching.baseline_replace.mode                       = struct('visible', 'on', 'type', 'combobox', 'default', {'none', 'trial', 'external'});                      % replace a baseline before/after events to  be epoched and processed: 


projectgui.epoching.baseline_replace.baseline_originalposition  = struct('visible', 'on', 'type', 'combobox', 'default', {'before', 'after'});                     % when replace the new baseline: the baseline segments to be inserted are originally 'before' or 'after' the events to  be epoched and processed                                                                                                                                                                             
projectgui.epoching.baseline_replace.baseline_finalposition     = struct('visible', 'on', 'type', 'combobox', 'default', {'before', 'after'});                     % when replace the new baseline: the baseline segments are inserted 'before' or 'after' the events to  be epoched and processed                                                                                 

projectgui.epoching.baseline_replace.trial_begin_marker         = projectgui.preproc.marker_type.begin_trial;
projectgui.epoching.baseline_replace.trial_end_marker           = projectgui.preproc.marker_type.end_trial;

projectgui.epoching.baseline_replace.baseline_begin_marker      = projectgui.preproc.marker_type.begin_baseline;                         % default 
projectgui.epoching.baseline_replace.baseline_end_marker        = projectgui.preproc.marker_type.end_baseline;

projectgui.epoching.baseline_replace.replace                    = struct('visible', 'on', 'type', 'combobox', 'default', {'all', 'part'});                    % 'all' 'part' replace all the pre/post marker period with a replicated baseline or replace the baseline at the begin (final position 'before') or at the end (final position 'after') of the recostructed baseline

                                                                                                             

% EEG
projectgui.epoching.input_suffix           = struct('visible', 'on', 'type', 'input', 'default', '_mc');                        % G1:   final file name before epoching : default is '_raw_mc'
projectgui.epoching.input_folder           = struct('visible', 'on', 'type', 'input', 'default', 'selfvar');                    % G2:   input epoch folder, by default the preprocessing output folder
projectgui.epoching.bc_type                = struct('visible', 'on', 'type', 'combobox', 'default', {'global', 'condition', 'trial'});                     % G3:   type of baseline correction: global: considering all the trials, 'condition': by condition, 'trial': trial-by-trial

projectgui.epoching.epo_st.s               = struct('visible', 'on', 'type', 'input', 'default', 0);                        % G4:   EEG epochs start latency
projectgui.epoching.epo_end.s              = struct('visible', 'on', 'type', 'input', 'default', 0);                            % G5:   EEG epochs end latency
projectgui.epoching.bc_st.s                = struct('visible', 'on', 'type', 'input', 'default', 0);                         % G6:   EEG baseline correction start latency
projectgui.epoching.bc_end.s               = struct('visible', 'on', 'type', 'input', 'default', 0);                       % G7:   EEG baseline correction end latency
projectgui.epoching.baseline_duration.s    = struct('visible', 'on', 'type', 'input', 'default', 'selfvar');

% point
projectgui.epoching.bc_st_point            = struct('visible', 'off', 'type', 'label', 'default', 'selfvar');       % G7:   EEG baseline correction start point
projectgui.epoching.bc_end_point           = struct('visible', 'off', 'type', 'label', 'default', 'selfvar');       % G8:   EEG baseline correction end point

% EMG
projectgui.epoching.emg_epo_st.s           = struct('visible', 'on', 'type', 'input', 'default', 0);                        % G9:   EMG epochs start latency
projectgui.epoching.emg_epo_end.s          = struct('visible', 'on', 'type', 'input', 'default', 0);                            % G10:  EMG epochs end latency
projectgui.epoching.emg_bc_st.s            = struct('visible', 'on', 'type', 'input', 'default', 0);                         % G11:  EMG baseline correction start latency
projectgui.epoching.emg_bc_end.s           = struct('visible', 'on', 'type', 'input', 'default', 0);                       % G12:  EMG baseline correction end latency

% point
projectgui.epoching.emg_bc_st_point        = struct('visible', 'off', 'type', 'label', 'default', 'selfvar'); % G13:   EMG baseline correction start point
projectgui.epoching.emg_bc_end_point       = struct('visible', 'off', 'type', 'label', 'default', 'selfvar'); % G14:   EMG baseline correction end point

% markers
projectgui.epoching.mrkcode_cond = { ...
                                {'11' '12' '13' '14' '15' '16'};...     % G15:  triggers defining conditions...even if only one trigger is used for each condition, a cell matrix is used
                                {'21' '22' '23' '24' '25' '26'};...            
                                {'31' '32' '33' '34' '35' '36'};...
                                {'41' '42' '43' '44' '45' '46'};...  
                              };
projectgui.epoching.numcond        = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');       % G16: conditions' number 
projectgui.epoching.valid_marker   = [projectgui.epoching.mrkcode_cond{1:length(projectgui.epoching.mrkcode_cond)}];

projectgui.epoching.condition_names={'control' 'AO' 'AOCS' 'AOIS'};        % G 17: conditions' labels
if length(projectgui.epoching.condition_names) ~= projectgui.epoching.numcond
    disp('ERROR in projectgui_structure: number of conditions do not coincide !!! please verify')
end
%% ======================================================================================================
% H:    SUBJECTS
% ======================================================================================================
% non c'e' completa coerenza con il valore gruppo definito a livello di singolo soggetto, e le liste presenti in groups

% 'baseline_file' is used when baseline must be adjusted around target events used for epoching, 
% i.e. when pre or post period of target event cannot be considered a good baseline (e.g for trials of different durations).
% 'baseline_file' is the short name (without the path) of the file from
% which baseline segments must be extracted in 'external' baseline adjustment mode, i.e. when there
% is no baseline within each trial. If empty, baseline segments are
% extracted from the same file with the target events.

% 'baseline_file_interval_s'is the time interval in from which baseline
% segments are extracted in 'baseline_file'. actually it is used to create
% baseline epochs (i.e. to insert baseline begin and end markers) in a selected period.
% only if 'baseline_file' is NOT empty (if baseline markers are placed in an external baseline file) 
% and 'baseline_file_interval_s' is empty the whole duration of the file is used to
% insert baseline markers. Instead for empty 'baseline_file' (i.e. if baseline markers are placed in the same file of target markers)
% 'baseline_file_interval_s' is MANDATORY non-empty (i.e. must be
% specified)

if isfield(projectgui, 'subjects')
    if isfield(projectgui.subjects, 'data')
        projectgui.subjects = rmfield(projectgui.subjects, 'data');
    end
end

projectgui.subjects.data(1)  = struct('name', 'CC_01_vittoria', 'group', 'CC', 'age', 13, 'gender', 'f', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(2)  = struct('name', 'CC_02_fabio',    'group', 'CC', 'age', 12, 'gender', 'm', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(3)  = struct('name', 'CC_03_anna',     'group', 'CC', 'age', 12, 'gender', 'f', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(4)  = struct('name', 'CC_04_giacomo',  'group', 'CC', 'age', 8,  'gender', 'm', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(5)  = struct('name', 'CC_05_stefano',  'group', 'CC', 'age', 9,  'gender', 'm', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(6)  = struct('name', 'CC_06_giovanni', 'group', 'CC', 'age', 6,  'gender', 'm', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(7)  = struct('name', 'CC_07_davide',   'group', 'CC', 'age', 11, 'gender', 'm', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(8)  = struct('name', 'CC_08_jonathan', 'group', 'CC', 'age', 8,  'gender', 'm', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(9)  = struct('name', 'CC_09_antonella','group', 'CC', 'age', 9,  'gender', 'f', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(10) = struct('name', 'CC_10_chiara',   'group', 'CC', 'age', 11, 'gender', 'f', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);


projectgui.subjects.data(11) = struct('name', 'CP_01_riccardo', 'group', 'CP', 'age', 6,  'gender', 'm', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(12) = struct('name', 'CP_02_ester',    'group', 'CP', 'age', 8,  'gender', 'f', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(13) = struct('name', 'CP_03_sara',     'group', 'CP', 'age', 11, 'gender', 'f', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(14) = struct('name', 'CP_04_matteo',   'group', 'CP', 'age', 10, 'gender', 'm', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(15) = struct('name', 'CP_05_gregorio', 'group', 'CP', 'age', 6,  'gender', 'm', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(16) = struct('name', 'CP_06_fernando', 'group', 'CP', 'age', 8,  'gender', 'm', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(17) = struct('name', 'CP_07_roberta',  'group', 'CP', 'age', 9,  'gender', 'f', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(18) = struct('name', 'CP_08_mattia',   'group', 'CP', 'age', 7,  'gender', 'm', 'handedness', 'r', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(19) = struct('name', 'CP_09_alessia',  'group', 'CP', 'age', 10, 'gender', 'f', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
projectgui.subjects.data(20) = struct('name', 'CP_10_livia',    'group', 'CP', 'age', 10, 'gender', 'm', 'handedness', 'l', 'bad_ch', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);

projectgui.subjects.data(16).bad_ch    = {'P1'};
projectgui.subjects.data(6).bad_ch     = {'PO3'};


...projectgui.subjects.data(1).frequency_bands_list = {[4,8];[5,9];[14,20];[20,32]};
...projectgui.subjects.data(6).frequency_bands_list = {[4,8];[6,10];[14,20];[20,32]};


projectgui.subjects.list               = {projectgui.subjects.data.name};
projectgui.subjects.numsubj            = length(projectgui.subjects.list);

projectgui.subjects.group_names        = {'CC', 'CP'};
projectgui.subjects.groups             = {{'CC_01_vittoria', 'CC_02_fabio','CC_03_anna', 'CC_04_giacomo', 'CC_05_stefano', 'CC_06_giovanni', 'CC_07_davide', 'CC_08_jonathan', 'CC_09_antonella', 'CC_10_chiara'}; ...
                                      {'CP_01_riccardo', 'CP_02_ester', 'CP_03_sara', 'CP_04_matteo', 'CP_05_gregorio', 'CP_06_fernando', 'CP_07_roberta', 'CP_08_mattia', 'CP_09_alessia', 'CP_10_livia'} ...
                                      };

%% ======================================================================================================
% I:    STUDY
% ======================================================================================================
projectgui.study.filename                          = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');

% structures that associates conditions' file with (multiple) factor(s)

% IMPORTANT NOTE: as additional factors are added to the EEG.event
% structure as new fields, you cannot call the new factor names using
% mathematical operators, which are wrongly intrepretated by matlab. eg,
% replace the name 'condition-group' with 'condition_group' or
% 'conditionGroup' OR 'conditionXgroup'


if isfield(projectgui, 'study')
    if isfield(projectgui.study, 'factors')
        projectgui.study = rmfield(projectgui.study, 'factors');
    end
end

projectgui.study.factors(1)                        = struct('factor', 'motion', 'file_match', [], 'level', 'translating');
projectgui.study.factors(2)                        = struct('factor', 'motion', 'file_match', [], 'level', 'centered');
projectgui.study.factors(3)                        = struct('factor', 'shape' , 'file_match', [], 'level', 'walker');
projectgui.study.factors(4)                        = struct('factor', 'shape' , 'file_match', [], 'level', 'scrambled');

projectgui.study.factors(1).file_match             = {'twalker', 'tscrambled'};
projectgui.study.factors(2).file_match             = {'cwalker', 'cscrambled'};
projectgui.study.factors(3).file_match             = {'twalker', 'cwalker'};
projectgui.study.factors(4).file_match             = {'tscrambled', 'cscrambled'};

% ERP
projectgui.study.erp.tmin_analysis.s               = struct('visible', 'on', 'type', 'input', 'default', 'selfvar');
projectgui.study.erp.tmax_analysis.s               = struct('visible', 'on', 'type', 'input', 'default', 'selfvar');
projectgui.study.erp.ts_analysis.s                 = struct('visible', 'on', 'type', 'input', 'default', 0.008);
projectgui.study.erp.timeout_analysis_interval.s   = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');

% ERSP
projectgui.study.ersp.tmin_analysis.s              = struct('visible', 'on', 'type', 'input', 'default', 'selfvar');
projectgui.study.ersp.tmax_analysis.s              = struct('visible', 'on', 'type', 'input', 'default', 'selfvar');
projectgui.study.ersp.ts_analysis.s                = struct('visible', 'on', 'type', 'input', 'default', 0.008);
projectgui.study.ersp.timeout_analysis_interval.s  = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');

projectgui.study.ersp.fmin_analysis                = struct('visible', 'on', 'type', 'input', 'default', 4);
projectgui.study.ersp.fmax_analysis                = struct('visible', 'on', 'type', 'input', 'default', 32);
projectgui.study.ersp.fs_analysis                  = struct('visible', 'on', 'type', 'input', 'default', 0.5);
projectgui.study.ersp.freqout_analysis_interval    = struct('visible', 'on', 'type', 'input', 'default', 'selfvar');
projectgui.study.ersp.padratio                     = struct('visible', 'on', 'type', 'input', 'default', 16);
projectgui.study.ersp.cycles                       = 0; ...[3 0.8];


projectgui.study.precompute.recompute              = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');
projectgui.study.precompute.do_erp                 = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');
projectgui.study.precompute.do_ersp                = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');
projectgui.study.precompute.do_erpim               = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');
projectgui.study.precompute.do_spec                = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');

projectgui.study.precompute.erp                    = {'interp','off','allcomps','on','erp'  ,'on','erpparams'  ,{},'recompute','off'};
projectgui.study.precompute.erpim                  = {'interp','off','allcomps','on','erpim','on','erpimparams',{'nlines' 10 'smoothing' 10},'recompute','off'};
projectgui.study.precompute.spec                   = {'interp','off','allcomps','on','spec' ,'on','specparams' ,{'specmode' 'fft','freqs' projectgui.study.ersp.freqout_analysis_interval},'recompute','off'};
projectgui.study.precompute.ersp                   = {'interp','off' ,'allcomps','on','ersp' ,'on','erspparams' ,{'cycles' projectgui.study.ersp.cycles,  'freqs', projectgui.study.ersp.freqout_analysis_interval, 'timesout', projectgui.study.ersp.timeout_analysis_interval.s*1000, ...
                                                   'freqscale','linear','padratio',projectgui.study.ersp.padratio, 'baseline',[projectgui.epoching.bc_st.s*1000 projectgui.epoching.bc_end.s*1000] },'itc','on','recompute','off'};


%% ======================================================================================================
% L:    DESIGN
% ======================================================================================================
if isfield(projectgui, 'design')
    projectgui = rmfield(projectgui, 'design');
end

projectgui.design(2)                   = struct('name',  'ao_control_ungrouped'   , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(3)                   = struct('name',  'aocs_control_ungrouped' , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(4)                   = struct('name',  'aocs_ao_ungrouped'      , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(5)                   = struct('name',  'aois_ao_ungrouped'      , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(6)                   = struct('name',  'aocs_aois_ungrouped'    , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(7)                   = struct('name',  'sound_effect_ungrouped' , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(8)                   = struct('name',  'ao_control'             , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(9)                   = struct('name',  'aocs_control'           , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(10)                  = struct('name', 'aocs_ao'                 , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(11)                  = struct('name', 'aois_ao'                 , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(12)                  = struct('name', 'aocs_aois'               , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
projectgui.design(13)                  = struct('name', 'sound_effect'            , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');

projectgui.design(2).factor1_levels    = {'AO','control'};
projectgui.design(3).factor1_levels    = {'AOCS','control'};
projectgui.design(4).factor1_levels    = {'AOCS','AO'};
projectgui.design(5).factor1_levels    = {'AOIS','AO'};
projectgui.design(6).factor1_levels    = {'AOCS','AOIS'};
projectgui.design(7).factor1_levels    = {'AOCS','AOIS','AO'};
projectgui.design(8).factor1_levels    = {'AO','control'};
projectgui.design(9).factor1_levels    = {'AOCS','control'};
projectgui.design(10).factor1_levels   = {'AOCS','AO'};
projectgui.design(11).factor1_levels   = {'AOIS','AO'};
projectgui.design(12).factor1_levels   = {'AOCS','AOIS'};
projectgui.design(13).factor1_levels   = {'AOCS','AOIS','AO'};

projectgui.design(8).factor2_levels    = {'CC','CP'};
projectgui.design(9).factor2_levels    = {'CC','CP'};
projectgui.design(10).factor2_levels   = {'CC','CP'};
projectgui.design(11).factor2_levels   = {'CC','CP'};
projectgui.design(12).factor2_levels   = {'CC','CP'};
projectgui.design(13).factor2_levels   = {'CC','CP'};

projectgui.design(1).factor1_levels    = {'cwalker' 'twalker' 'cscrambled' 'tscrambled'};
projectgui.design(2).factor1_levels    = {'centered','translating'};
projectgui.design(3).factor1_levels    = {'scrambled','walker'};
projectgui.design(4).factor1_levels    = {'scrambled','walker'};
projectgui.design(4).factor2_levels    = {'centered','translating'};
%% ======================================================================================================
% M:    STATS
% ======================================================================================================
% ERP
projectgui.stats.erp.pvalue                        = struct('visible', 'on', 'type', 'input', 'default', 0.05);       % level of significance applied in ERP statistical analysis
projectgui.stats.erp.num_permutations              = struct('visible', 'on', 'type', 'input', 'default', 20000);                    % number of permutations applied in ERP statistical analysis
projectgui.stats.erp.num_tails                     = struct('visible', 'on', 'type', 'input', 'default', 2);
projectgui.stats.eeglab.erp.method                 = 'bootstrap';          % method applied in ERP statistical analysis
projectgui.stats.eeglab.erp.correction             = struct('visible', 'on', 'type', 'combobox', 'default', {'none', 'fdr', 'fwe'});                % multiple comparison correction applied in ERP statistical analysis

% ERSP
projectgui.stats.ersp.pvalue                       = struct('visible', 'on', 'type', 'input', 'default', 0.05);        % level of significance applied in ERSP statistical analysis
projectgui.stats.ersp.num_permutations             = struct('visible', 'on', 'type', 'input', 'default', 3);                    % number of permutations applied in ERP statistical analysis
projectgui.stats.ersp.num_tails                    = struct('visible', 'on', 'type', 'input', 'default', 2);
projectgui.stats.ersp.decimation_factor_times_tf   = struct('visible', 'on', 'type', 'input', 'default', 10);
projectgui.stats.ersp.decimation_factor_freqs_tf   = struct('visible', 'on', 'type', 'input', 'default', 10);
projectgui.stats.ersp.tf_resolution_mode           = struct('visible', 'on', 'type', 'combobox', 'default', {'continuous', 'decimate_times', 'decimate_freqs', 'tw_fb'});
projectgui.stats.ersp.measure                      = struct('visible', 'on', 'type', 'combobox', 'default', {'dB', 'Pfu'});                 % 'Pfu';  dB decibel, Pfu, (A-R)/R * 100 = (A/R-1) * 100 = (10^.(ERSP/10)-1)*100 variazione percentuale definita da pfursheller

projectgui.stats.ersp.do_narrowband                = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');                         % on|off enable/disable the adjustment of spectral band for each subject
projectgui.stats.ersp.narrowband.group_tmin        = [];                     % lowest time of the time windows considered to select the narrow band. if empty, consider the start of the epoch
projectgui.stats.ersp.narrowband.group_tmax        = [];                     % highest time of the time windows considered to select the narrow band. if empty, consider the end of the epoch
projectgui.stats.ersp.narrowband.dfmin             = struct('visible', 'on', 'type', 'input', 'default', 2);                         % low variation in Hz from the barycenter frequency
projectgui.stats.ersp.narrowband.dfmax             = struct('visible', 'on', 'type', 'input', 'default', 2);                         % high variation in Hz from the barycenter frequency
projectgui.stats.ersp.narrowband.which_realign_measure = {'max','min','min','auc'}; % min |max |auc for each band, select the frequency with the maximum or the minumum ersp or the largest area under the curve to reallign the narrowband

projectgui.stats.eeglab.ersp.method                = 'bootstrap';          % method applied in ERP statistical analysis
projectgui.stats.eeglab.ersp.correction            = struct('visible', 'on', 'type', 'combobox', 'default', {'none', 'fdr', 'fwe'});               % multiple comparison correction applied in ERP statistical analysis


% BRAINSTORM 
projectgui.stats.brainstorm.pvalue                 = struct('visible', 'on', 'type', 'input', 'default', 0.05);       % level of significance applied in ERSP statistical analysis
projectgui.stats.brainstorm.correction             = struct('visible', 'on', 'type', 'combobox', 'default', {'none', 'fdr', 'fwe'});                % multiple comparison correction applied in ERP statistical analysis

% SPM
projectgui.stats.spm.pvalue                        = struct('visible', 'on', 'type', 'input', 'default', 0.05);       % level of significance applied in ERSP statistical analysis
projectgui.stats.spm.correction                    = struct('visible', 'on', 'type', 'combobox', 'default', {'none', 'fdr', 'fwe'});                % multiple comparison correction applied in ERP statistical analysis

% for each design of interest, perform or not statistical analysis of erp
projectgui.stats.show_statistics_list              = {'on','on','on','on','on','on','on','on'};   

%% ======================================================================================================
% N:    POSTPROCESS
% ======================================================================================================

% ERP

projectgui.postprocess.erp.mode.continous           = struct('time_resolution_mode', 'continuous', 'peak_type', 'off'          , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
projectgui.postprocess.erp.mode.tw_group_noalign    = struct('time_resolution_mode', 'tw'        , 'peak_type', 'group'        , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
projectgui.postprocess.erp.mode.tw_group_align      = struct('time_resolution_mode', 'tw'        , 'peak_type', 'group'        , 'align', 'on',  'tw_stat_estimator', 'tw_extremum');
projectgui.postprocess.erp.mode.tw_individual_noalign  = struct('time_resolution_mode', 'tw'        , 'peak_type', 'individual'   , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
projectgui.postprocess.erp.mode.tw_individual_align = struct('time_resolution_mode', 'tw'        , 'peak_type', 'individual'   , 'align', 'on' , 'tw_stat_estimator', 'tw_extremum');


projectgui.postprocess.erp.sel_extrema              = struct('visible', 'on', 'type', 'combobox', 'default', {'first_occurrence', 'avg_occurrences'});


projectgui.postprocess.erp.roi_list = {  ...
          {'F5','F7','AF7','FT7'};  ... left IFG
          {'F6','F8','AF8','FT8'};  ... right IFG
          {'FC3','FC5'};            ... l PMD
          {'FC4','FC6'};            ... r PMD    
          {'C3'};                   ... iM1 hand
          {'C4'};                   ... cM1 hand
          {'Cz'}

};
projectgui.postprocess.erp.roi_names={'left-ifg','right-ifg','left-PMd','right-PMd','left-SM1','right-SM1','SMA'}; ...,'left-ipl','right-ipl','left-spl','right-spl','left-sts','right-sts','left-occipital','right-occipital'};
projectgui.postprocess.erp.numroi=length(projectgui.postprocess.erp.roi_list);

if isfield(projectgui, 'postprocess')
    if isfield(projectgui.postprocess, 'erp')
        if isfield(projectgui.postprocess.erp, 'design')
            projectgui.postprocess.erp = rmfield(projectgui.postprocess.erp, 'design');
        end
    end
end


projectgui.postprocess.erp.design(1).group_time_windows(1)     = struct('name','350-650','min',350, 'max',650);
projectgui.postprocess.erp.design(1).group_time_windows(2)     = struct('name','750-1500','min',750, 'max',1500);
projectgui.postprocess.erp.design(1).group_time_windows(3)     = struct('name','1700-2996','min',1700, 'max',2996);
projectgui.postprocess.erp.design(1).group_time_windows(4)     = struct('name','750','min',0, 'max',2996);

projectgui.postprocess.erp.design(1).subject_time_windows(1)   = struct('min',-100, 'max',100);
projectgui.postprocess.erp.design(1).subject_time_windows(2)   = struct('min',-100, 'max',100);
projectgui.postprocess.erp.design(1).subject_time_windows(3)   = struct('min',-100, 'max',100);
projectgui.postprocess.erp.design(1).subject_time_windows(4)   = struct('min',-100, 'max',100);

projectgui.postprocess.erp.design(1).which_extrema_curve       = {  ... design x roi x time_windows
                            ...   tw1   tw2  ...
                                {'max';'min';'min';'min'}; ... roi 1
                                {'max';'min';'min';'min'}; ... roi 2
                                {'max';'min';'min';'min'}; ... roi 3
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}; ...
                                {'max';'min';'min';'min'}  ...112
};

for ds=2:length(projectgui.design)
    projectgui.postprocess.erp.design(ds) = projectgui.postprocess.erp.design(1);
end


%% ===============================================================================================================================================================
% ERSP 
%===============================================================================================================================================================

projectgui.postprocess.ersp.sel_extrema                            = struct('visible', 'on', 'type', 'combobox', 'default', {'first_occurrence', 'avg_occurrences'});

projectgui.postprocess.ersp.mode.continous                         = struct('time_resolution_mode', 'continuous', 'peak_type', 'off'          , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
projectgui.postprocess.ersp.mode.tw_group_noalign                  = struct('time_resolution_mode', 'tw'        , 'peak_type', 'group'        , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
projectgui.postprocess.ersp.mode.tw_group_align                    = struct('time_resolution_mode', 'tw'        , 'peak_type', 'group'        , 'align', 'on',  'tw_stat_estimator', 'tw_extremum');
projectgui.postprocess.ersp.mode.tw_individual_noalign             = struct('time_resolution_mode', 'tw'        , 'peak_type', 'individual'   , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
projectgui.postprocess.ersp.mode.tw_individual_align               = struct('time_resolution_mode', 'tw'        , 'peak_type', 'individual'   , 'align', 'on' , 'tw_stat_estimator', 'tw_extremum');

%===============================================================================
% FREQUENCY BANDS
%===============================================================================

if isfield(projectgui, 'postprocess')
    if isfield(projectgui.postprocess, 'ersp')
        if isfield(projectgui.postprocess.ersp, 'frequency_bands')
            projectgui.postprocess.ersp = rmfield(projectgui.postprocess.ersp, 'frequency_bands');
        end
    end
end

projectgui.postprocess.ersp.frequency_bands(1)         = struct('name','teta','min',3,'max',5,'ref_roi',[]);
projectgui.postprocess.ersp.frequency_bands(2)         = struct('name','mu','min',5,'max',8,'ref_roi',[]);
projectgui.postprocess.ersp.frequency_bands(3)         = struct('name','beta1','min',14, 'max',20,'ref_roi',[]);
projectgui.postprocess.ersp.frequency_bands(4)         = struct('name','beta2','min',20, 'max',32,'ref_roi',[]);


...projectgui.postprocess.ersp.frequency_bands(1).ref_roi = {'Fp1'};


projectgui.postprocess.ersp.nbands                      = struct('visible', 'off', 'type', 'label', 'default', 'selfvar');

projectgui.postprocess.ersp.frequency_bands_list        = {}; ... writes something like {[4,8];[8,12];[14,20];[20,32]};
for fb=1:projectgui.postprocess.ersp.nbands
    bands                                               = [projectgui.postprocess.ersp.frequency_bands(fb).min, projectgui.postprocess.ersp.frequency_bands(fb).max];
    projectgui.postprocess.ersp.frequency_bands_list    = [projectgui.postprocess.ersp.frequency_bands_list; {bands}];
end
projectgui.postprocess.ersp.frequency_bands_names       = struct('visible', 'on', 'type', 'label', 'default', 'selfvar');

%===============================================================================
% ROI LIST
%===============================================================================

projectgui.postprocess.ersp.roi_list = { ...
          
          {'C4'};                   ... cM1 hand
          {'C3'};                   ... iM1 hand
          {'Cz'};                   ... SMA
          {'FC3','FC5'};            ... l PMD
          {'FC4','FC6'};            ... r PMD    
          {'F5','F7','AF7','FT7'};  ... left IFG
          {'F6','F8','AF8','FT8'}  ... right IFG
};
projectgui.postprocess.ersp.roi_names                              = {'contralateral-SM1','ipsilateral-SM1','SMA','ipsilateral-PMd','contralateral-PMd','ipsilateral-ifg','contralateral-ifg'}; ... ,'left-ipl','right-ipl','left-spl','right-spl','left-sts','right-sts','left-occipital','right-occipital'};
projectgui.postprocess.ersp.numroi                                 = struct('visible', 'off', 'type', 'label', 'default', 'selfvar');

if isfield(projectgui, 'postprocess')
    if isfield(projectgui.postprocess, 'ersp')
        if isfield(projectgui.postprocess.ersp, 'design')
            projectgui.postprocess.ersp = rmfield(projectgui.postprocess.ersp, 'design');
        end
    end
end

projectgui.postprocess.ersp.nroi = length(projectgui.postprocess.ersp.roi_list);
%===============================================================================
% DESIGNS' TIME WINDOWS
%===============================================================================

projectgui.postprocess.ersp.design(1).group_time_windows(1)        = struct('name','350-650','min',350, 'max',650);
projectgui.postprocess.ersp.design(1).group_time_windows(2)        = struct('name','750-1500','min',750, 'max',1500);
projectgui.postprocess.ersp.design(1).group_time_windows(3)        = struct('name','1700-2500','min',1700, 'max',2500);
projectgui.postprocess.ersp.design(1).group_time_windows(4)        = struct('name','350-2500','min',350, 'max',2500);
    

projectgui.postprocess.erp.design(1).group_time_windows(1).ref_roi = [projectgui.postprocess.erp.roi_list(1), projectgui.postprocess.erp.roi_list(6)];
projectgui.postprocess.erp.design(1).group_time_windows(2).ref_roi = [projectgui.postprocess.erp.roi_list(2), projectgui.postprocess.erp.roi_list(7)];
projectgui.postprocess.erp.design(1).group_time_windows(3).ref_roi = [projectgui.postprocess.erp.roi_list(1), projectgui.postprocess.erp.roi_list(6)];
projectgui.postprocess.erp.design(1).group_time_windows(4).ref_roi = [projectgui.postprocess.erp.roi_list(2), projectgui.postprocess.erp.roi_list(7)];

projectgui.postprocess.ersp.design(1).subject_time_windows(1)      = struct('min',-100, 'max',100);
projectgui.postprocess.ersp.design(1).subject_time_windows(2)      = struct('min',-100, 'max',100);
projectgui.postprocess.ersp.design(1).subject_time_windows(3)      = struct('min',-100, 'max',100);
projectgui.postprocess.ersp.design(1).subject_time_windows(4)      = struct('min',-100, 'max',100);



% extreme to be searched in the continuous curve ( NON time-window mode)
projectgui.postprocess.ersp.design(1).which_extrema_curve_continuous = {     .... design x roi x freq band
                                    {... roi
                                        {'max'};... frequency band
                                        {'min'};...
                                        {'min'}; ...
                                        {'min'}...
                                    };
                                    {... roi
                                        {'max'};... frequency band
                                        {'min'};...
                                        {'min'}; ...
                                        {'min'}...
                                    };
                                    {... roi
                                        {'max'};... frequency band
                                        {'min'};...
                                        {'min'}; ...
                                        {'min'}...
                                    };                                    
                                    {... roi
                                        {'max'};... frequency band
                                        {'min'};...
                                        {'min'}; ...
                                        {'min'}...
                                    };
                                    {... roi
                                        {'max'};... frequency band
                                        {'min'};...
                                        {'min'}; ...
                                        {'min'}...
                                    };
                                    {... roi
                                        {'max'};... frequency band
                                        {'min'};...
                                        {'min'}; ...
                                        {'min'}...
                                    };
};

% ****CHECK****
if size(projectgui.postprocess.ersp.design(1).which_extrema_curve_continuous, 1) ~= projectgui.postprocess.ersp.nroi
   error(['number of roi in which_extrema_curve_continuous parameters (' num2str(size(projectgui.postprocess.ersp.design(1).which_extrema_curve_continuous,1)) ') does not correspond to number of defined ROI (' num2str(projectgui.postprocess.ersp.nroi) ')']); 
else
    if size(projectgui.postprocess.ersp.design(1).which_extrema_curve_continuous{1}, 1) ~= projectgui.postprocess.ersp.nbands
        error(['number of bands in the first roi of which_extrema_curve_continuous parameters (' num2str(size(projectgui.postprocess.ersp.design(1).which_extrema_curve_continuous{1},1)) ') does not correspond to number of defined frequency bands (' num2str(projectgui.postprocess.ersp.nbands) ')']); 
    end
end
%*************

% time interval for searching extreme in the continuous curve ( NON time-window mode)
projectgui.postprocess.ersp.design(1).group_time_windows_continuous = {     .... design x roi x freq band
                                    {... roi
                                        {};... frequency band
                                        {};...
                                        {}; ...
                                        {}...
                                    };
                                    {... roi
                                        {};... frequency band
                                        {};...
                                        {}; ...
                                        {}...
                                    };
                                    {... roi
                                        {};... frequency band
                                        {};...
                                        {}; ...
                                        {}...
                                    };                                    
                                    {... roi
                                        {};... frequency band
                                        {};...
                                        {}; ...
                                        {}...
                                    };
                                     {... roi
                                        {};... frequency band
                                        {};...
                                        {}; ...
                                        {}...
                                    };                                  
};




% extreme to be searched in each time window (time-window mode)
projectgui.postprocess.ersp.design(1).which_extrema_curve_tw = {     .... design x roi x freq band x time window
                                    {... roi 1
                                    ...  tw1    tw2   tw3   tw4   tw5                                 
                                        {'max';'max';'max';'max';'max'}; ... frequency band 1
                                        {'min';'min';'min';'min';'min'}; ... frequency band 2
                                        {'min';'min';'min';'min';'min'}; ... frequency band 3
                                        {'min';'min';'min';'min';'min'}  ... frequency band 4
                                    };
                                    {... roi 2
                                        {'max';'max';'max';'max';'max'}; ... frequency band 1
                                        {'min';'min';'min';'min';'min'}; ... frequency band 2
                                        {'min';'min';'min';'min';'min'}; ... frequency band 3
                                        {'min';'min';'min';'min';'min'}  ... frequency band 4
                                    };
                                    {... roi 3
                                        {'max';'max';'max';'max';'max'}; ... frequency band 1
                                        {'min';'min';'min';'min';'min'}; ... frequency band 2
                                        {'min';'min';'min';'min';'min'}; ... frequency band 3
                                        {'min';'min';'min';'min';'min'}  ... frequency band 4
                                    };
};


for ds=2:length(projectgui.design)
    projectgui.postprocess.ersp.design(ds) = projectgui.postprocess.ersp.design(1);
end







%cla aggiungo questo per riordinare eventualmente in post-processing i
%livelli di qualche fattore

projectgui.postprocess.design_factors_ordered_levels={...
                                    ... reordered levels of factor 1               reordered levels of factor 2  
                              {{'cscrambled' 'cwalker' 'tscrambled' 'twalker'}                 {}                  };... design 1 for each desing, up to 2 factors
                              {{}                                                              {}                  };... design 2
                              {{}                                                              {}                  };...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
                              {{} {}};...
};


%% ======================================================================================================
% O:    RESULTS DISPLAY
% ======================================================================================================

% CURVES

% ERP
projectgui.results_display.erp.time_smoothing                      = struct('visible', 'on', 'type', 'input', 'default', 10);           % frequency (Hz) of low-pass filter to be applied (only for visualization) of ERP data
projectgui.results_display.erp.time_range.s                        = [projectgui.study.erp.tmin_analysis.s projectgui.study.erp.tmax_analysis.s];       % time range for erp representation

% ERP CURVE
projectgui.results_display.ylim_plot                               = [];           %y limits (uV)for the representation of ERP
projectgui.results_display.erp.single_subjects                     = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');       % display patterns of the single subjcts (keeping the average pattern)
projectgui.results_display.erp.masked_times_max                    = [];           % number of ms....all the timepoints before this values are not considered for statistics
projectgui.results_display.erp.do_plots                            = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');        %
projectgui.results_display.erp.show_text                           = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         %

projectgui.results_display.erp.compact_plots                       = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % display (curve) plots with different conditions/groups on the same plots
projectgui.results_display.erp.compact_h0                          = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % display parameters for compact plots
projectgui.results_display.erp.compact_v0                          = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         %
projectgui.results_display.erp.compact_sem                         = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');        %
projectgui.results_display.erp.compact_stats                       = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         %
projectgui.results_display.erp.compact_display_xlim                = [];           %
projectgui.results_display.erp.compact_display_ylim                = [];           %
projectgui.results_display.erp.display_only_significant_curve      = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % on

% ERP TOPO
projectgui.results_display.erp.compact_plots_topo                  = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');        %
projectgui.results_display.erp.set_caxis_topo_tw                   = [];           %
projectgui.results_display.erp.display_only_significant_topo       = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % on
projectgui.results_display.erp.display_only_significant_topo_mode  = struct('visible', 'on', 'type', 'combobox', 'default', {'surface', 'electrodes'});
projectgui.results_display.erp.display_compact_topo_mode           = struct('visible', 'on', 'type', 'combobox', 'default', {'boxplot', 'errorbar'});
projectgui.results_display.erp.display_compact_show_head           = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');        % 'on'|'off'
projectgui.results_display.erp.z_transform                         = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % 'on'|'off' z-transform data data for each roi, and tw to allow to plot all figures on the same scale


% ERSP
projectgui.results_display.ersp.time_range.s                       = [projectgui.study.ersp.tmin_analysis.s projectgui.study.ersp.tmax_analysis.s];     % time range for erp representation
projectgui.results_display.ersp.frequency_range                    = [projectgui.study.ersp.fmin_analysis projectgui.study.ersp.fmax_analysis];         % frequency range for ersp representation
projectgui.results_display.ersp.do_plots                           = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');        %
projectgui.results_display.ersp.show_text                          = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         %
projectgui.results_display.ersp.z_transform                        = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');              % 'on'|'off' z-transform data data for each roi, band and tw to allow to plot all figures on the same scale
projectgui.results_display.ersp.which_error_measure                = struct('visible', 'on', 'type', 'combobox', 'default', {'sd', 'sem'});     % 'sd'|'sem'; which error measure is adopted in the errorbar: standard deviation or standard error
projectgui.results_display.ersp.freq_scale                         = struct('visible', 'on', 'type', 'combobox', 'default', {'linear', 'log'}); % 'log'|'linear' set frequency scale in time-frequency plots
projectgui.results_display.ersp.masked_times_max                   = [];
projectgui.results_display.ersp.display_pmode                      = struct('visible', 'on', 'type', 'combobox', 'default', {'raw_diff', 'abs_diff', 'standard'});  % 'raw_diff' | 'abs_diff'| 'standard'; plot p values in a time-frequency space. 'raw_diff': for 2 levels factors, show p values multipled with the raw difference between the average of level 1 and the average of level 2; 'abs_diff': for 2 levels factors, show p values multipled with the difference betwenn the abs of the average of level 1 and the abs of the average of level 2 (more focused on the strength of the spectral variatio with respect to the sign of the variation); 'standard': the standard mode of EEGLab, only indicating a significant difference between levels, without providing information about the sign of the difference, it's the only representation avalillable for factors with >2 levels (for which a difference cannot be simply calculated). 

% ERSP CURVE
projectgui.results_display.ersp.compact_plots                      = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % display (curve) plots with different conditions/groups on the same plots
projectgui.results_display.ersp.single_subjects                    = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');        % display patterns of the single subjcts (keeping the average pattern)
projectgui.results_display.ersp.compact_h0                         = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % 'on'|'off'show x=0 axis
projectgui.results_display.ersp.compact_v0                         = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % 'on'|'off' show y=0 axis
projectgui.results_display.ersp.compact_sem                        = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');        % 'on'|'off' show standard error in compact plots (for compact topographic the error is always showed)
projectgui.results_display.ersp.compact_stats                      = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % 'on'|'off' indicate significant differences in the compact plots, using a black orizontal bar for continuous curve plots and stars for time-windows plots 
projectgui.results_display.ersp.compact_display_xlim               = [];           % [x_min x_max] set the x limits in ms for compact plots
projectgui.results_display.ersp.compact_display_ylim               = [];           % [y_min y_max] set the y limits for compact plots 
projectgui.results_display.ersp.stat_time_windows_list             = [];           % time windows in milliseconds [tw1_start,tw1_end; tw2_start,tw2_end] considered for statistics
projectgui.results_display.ersp.set_caxis_tf                       = [];           % [color_min color_max] set the color limits of the time-frequency plots 
projectgui.results_display.ersp.display_only_significant_curve     = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % on % the threshold is always set, however you can choose to display only the significant p values or all the p values (in the curve plots the threshold is added as a landmark)

% ERSP TF
projectgui.results_display.ersp.display_only_significant_tf        = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % 'on'|'off'display only significant values or all values
projectgui.results_display.ersp.display_only_significant_tf_mode   = struct('visible', 'on', 'type', 'combobox', 'default', {'binary', 'thresholded'}); % 'thresholded'|'binary'; plot comparison between time frequency distributions; thrsholded: show for each condition only ERSP correspoding to significant differences, binary: show classical EEGLAB representation 

% ERSP TOPO
projectgui.results_display.ersp.compact_plots_topo                 = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % 'on'|'off' for each time window, plot compact topographic plot with bot topographic location of the roi and multiple comparisons between conditions OR standard EEGLAB topographic distribution plots (consider the wolwe scalp)
projectgui.results_display.ersp.set_caxis_topo_tw_fb               = struct('visible', 'on', 'type', 'input', 'default', []);           % [color_min color_max] set the color limits of the topographic plots
projectgui.results_display.ersp.display_only_significant_topo      = struct('visible', 'on', 'type', 'checkbox', 'default', 'on');         % on|off display only significant values or all values
projectgui.results_display.ersp.display_only_significant_topo_mode = struct('visible', 'on', 'type', 'combobox', 'default', {'surface', 'electrodes'}); % 'surface'|'electrodes' change the way to show significant differences: show an interpolated surface between electrodes with significant differences or classical representation, i.e. significant electrodes in red
projectgui.results_display.ersp.display_compact_topo_mode          = struct('visible', 'on', 'type', 'combobox', 'default', {'boxplot', 'errorbar'});   % 'boxplot'|'errorbar' display boxplot with single subjects represented by red points (complete information about distribution) or error bar (syntetic standard representation)
projectgui.results_display.ersp.display_compact_show_head          = struct('visible', 'on', 'type', 'checkbox', 'default', 'off');        %'on'|'off' show the topographical representation of the roi (the head with the channels of the roi in red and te others in black)










































%% ======================================================================================================
% P:    EXPORT
% ======================================================================================================
export.r.bands=[];
for nband=1:length(projectgui.postprocess.ersp.frequency_bands_names)
    export.r.bands(nband).freq          = projectgui.postprocess.ersp.frequency_bands_list{nband};
    export.r.bands(nband).name          = projectgui.postprocess.ersp.frequency_bands_names{nband};
end

%% ======================================================================================================
% Q:    CLUSTERING
% ======================================================================================================
projectgui.clustering.channels_file_name           = 'cluster_projectguiion_channel_locations.loc';
projectgui.clustering.channels_file_path           = ''; ... later set by define_paths

%% ======================================================================================================
% R:    BRAINSTORM
% ======================================================================================================
projectgui.brainstorm.db_name                      = 'healthy_action_observation_sound';                  ... must correspond to brainstorm db name

projectgui.brainstorm.paths.db                     = '';
projectgui.brainstorm.paths.data                   = '';
projectgui.brainstorm.paths.channels_file          = '';

projectgui.brainstorm.sources.sources_norm         = 'wmne';        % possible values are: wmne, dspm, sloreta
projectgui.brainstorm.sources.source_orient        = 'fixed';      % possible values are: fixed, loose
projectgui.brainstorm.sources.loose_value          = 0.2;
projectgui.brainstorm.sources.depth_weighting      = 'nodepth';   % optional parameter, actually it is enabled for wmne and dspm and disabled for sloreta
projectgui.brainstorm.sources.downsample_atlasname = 's3000';

projectgui.brainstorm.analysis_bands={{ ...
                    projectgui.postprocess.ersp.frequency_bands(1).name, [num2str(projectgui.postprocess.ersp.frequency_bands(1).min) ', ' num2str(projectgui.postprocess.ersp.frequency_bands(1).max)], 'mean'; ...
                    projectgui.postprocess.ersp.frequency_bands(2).name, [num2str(projectgui.postprocess.ersp.frequency_bands(2).min) ', ' num2str(projectgui.postprocess.ersp.frequency_bands(2).max)], 'mean'; ...
                    projectgui.postprocess.ersp.frequency_bands(3).name, [num2str(projectgui.postprocess.ersp.frequency_bands(3).min) ', ' num2str(projectgui.postprocess.ersp.frequency_bands(3).max)], 'mean'; ...
                    projectgui.postprocess.ersp.frequency_bands(4).name, [num2str(projectgui.postprocess.ersp.frequency_bands(4).min) ', ' num2str(projectgui.postprocess.ersp.frequency_bands(4).max)], 'mean' ...
                                  }};
                                  
projectgui.brainstorm.analysis_times               = {{'t-4', '-0.4000, -0.3040', 'mean'; 't-3', '-0.3000, -0.2040', 'mean'; 't-2', '-0.2000, -0.1040', 'mean'; 't-1', '-0.1000, -0.0040', 'mean'; 't1', '0.0000, 0.0960', 'mean'; 't2', '0.1000, 0.1960', 'mean'; 't3', '0.2000, 0.2960', 'mean'; 't4', '0.3000, 0.3960', 'mean'; 't5', '0.4000, 0.4960', 'mean'; 't6', '0.5000, 0.5960', 'mean'; 't7', '0.6000, 0.6960', 'mean'; 't8', '0.7000, 0.7960', 'mean'; 't9', '0.8000, 0.8960', 'mean'; 't10', '0.9000, 0.9960', 'mean'}};

projectgui.brainstorm.conductorvolume.type         = 1;
projectgui.brainstorm.conductorvolume.surf_bem_file_name = 'headmodel_surf_openmeeg.mat';
projectgui.brainstorm.conductorvolume.vol_bem_file_name  = 'headmodel_vol_openmeeg.mat';

if projectgui.brainstorm.conductorvolume.type == 1
    projectgui.brainstorm.conductorvolume.bem_file_name = projectgui.brainstorm.conductorvolume.surf_bem_file_name;
else
    projectgui.brainstorm.conductorvolume.bem_file_name = projectgui.brainstorm.conductorvolume.vol_bem_file_name;
end

projectgui.brainstorm.use_same_montage                 = 1;
projectgui.brainstorm.default_anatomy                  = 'MNI_Colin27';
projectgui.brainstorm.channels_file_name               = 'brainstorm_channel.pos';
projectgui.brainstorm.channels_file_type               = 'BST';  ... 'POLHEMUS'
projectgui.brainstorm.channels_file_path               = ''; ... later set by define_paths

projectgui.brainstorm.export.spm_vol_downsampling      = 2;
projectgui.brainstorm.export.spm_time_downsampling     = 1;

projectgui.brainstorm.std_loose_value                  = 0.2;

projectgui.brainstorm.average_file_name                = 'data_average';
projectgui.brainstorm.stats.ttest_abstype              = 1;
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================



















% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% DERIVED TIMES from seconds to milliseconds
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================

% ======================================================================================================
% EPOCHING
% ======================================================================================================

%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
projectgui.epoching.bc_st.ms   = projectgui.epoching.bc_st.s*1000;            % baseline correction start latency
projectgui.epoching.bc_end.ms  = projectgui.epoching.bc_end.s*1000;           % baseline correction end latency
projectgui.epoching.epo_st.ms  = projectgui.epoching.epo_st.s*1000;             % epochs start latency
projectgui.epoching.epo_end.ms = projectgui.epoching.epo_end.s*1000;             % epochs end latency

projectgui.epoching.baseline_mark.baseline_begin_target_marker_delay.ms = projectgui.epoching.baseline_mark.baseline_begin_target_marker_delay.s *1000; % delay  between target and baseline begin marker to be inserted

%  ********* /DERIVED DATA *****************************************************************


% ======================================================================================================
% POSTPROCESS
% ======================================================================================================

%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
projectgui.postprocess.eeglab.frequency_bands_list={ ...
    [projectgui.postprocess.ersp.frequency_bands(1).min,projectgui.postprocess.ersp.frequency_bands(1).max]; ... 
    [projectgui.postprocess.ersp.frequency_bands(2).min,projectgui.postprocess.ersp.frequency_bands(2).max]; ...
    [projectgui.postprocess.ersp.frequency_bands(3).min,projectgui.postprocess.ersp.frequency_bands(3).max]; ...
    [projectgui.postprocess.ersp.frequency_bands(4).min,projectgui.postprocess.ersp.frequency_bands(4).max]; ...
    };
projectgui.postprocess.eeglab.frequency_bands_names    = {projectgui.postprocess.ersp.frequency_bands(1).name,projectgui.postprocess.ersp.frequency_bands(2).name,projectgui.postprocess.ersp.frequency_bands(3).name,projectgui.postprocess.ersp.frequency_bands(4).name};
%  ********* /DERIVED DATA  *****************************************************************


% ERP
%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
projectgui.study.erp.tmin_analysis.ms                  = projectgui.study.erp.tmin_analysis.s*1000;
projectgui.study.erp.tmax_analysis.ms                  = projectgui.study.erp.tmax_analysis.s*1000;
projectgui.study.erp.ts_analysis.ms                    = projectgui.study.erp.ts_analysis.s*1000;
projectgui.study.erp.timeout_analysis_interval.ms      = projectgui.study.erp.timeout_analysis_interval.s*1000;
%  ********* /DERIVED DATA  *****************************************************************


% ERSP
%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
projectgui.study.ersp.tmin_analysis.ms                 = projectgui.study.ersp.tmin_analysis.s*1000;
projectgui.study.ersp.tmax_analysis.ms                 = projectgui.study.ersp.tmax_analysis.s*1000;
projectgui.study.ersp.ts_analysis.ms                   = projectgui.study.ersp.ts_analysis.s*1000;
projectgui.study.ersp.timeout_analysis_interval.ms     = projectgui.study.ersp.timeout_analysis_interval.s*1000;
%  ********* /DERIVED DATA  *****************************************************************


% ======================================================================================================
% RESULTS DISPLAY
% ======================================================================================================
% insert parameters for ERP and TF analysis in the STUDY

%frequency (Hz) of low-pass filter to be applied (only for visualization) of ERP data
projectgui.results_display.filter_freq                 = 10;
%y limits (uV)for the representation of ERP
projectgui.results_display.ylim_plot                   = [-2.5 2.5];
      
%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
projectgui.results_display.erp.time_range.ms           = projectgui.results_display.erp.time_range.s*1000;
projectgui.results_display.ersp.time_range.ms          = projectgui.results_display.ersp.time_range.s*1000;
%  ********* /DERIVED DATA  *****************************************************************

% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================
% ======================================================================================================



