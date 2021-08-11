 %% project
% from 3/10/16 previous complex structures are cleared by a specific function 
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
%% ======================================================================================================
% A:    START
% ======================================================================================================
...project.research_group                           % A1: set in main: e.g.  PAP or MNI
...project.research_subgroup                        % A2: set in main: e.g.  PAP or MNI
...project.name                                     % A3: set in main : must correspond to 'project.paths.local_projects_data' subfolder name

project.study_suffix                                = '';                   % A4: sub name used to create a different STUDY name (fianl file will be called: [project.name project.study_suffix '.study'])
project.analysis_name                               = 'test';    % A5: epoching output folder name, subfolder containing the condition files of the current analysis type

project.operations.do_source_analysis               = 0;                    % A6:  
project.operations.do_emg_analysis                  = 0;                    % A7:
project.operations.do_cluster_analysis              = 0;                    % A8:
project.operations.do_fieldtrip_analysis            = 0;                    % A8:

%% ======================================================================================================
% B:    PATHS  
% ======================================================================================================
% set by: main file
...project.paths.projects_data_root                 % B1:   folder containing local RBCS projects root-folder,  set in main
...project.paths.svn_scripts_root                   % B2:   folder containing local RBCS script root-folder,  set in main
...project.paths.plugins_root                       % B3:   folder containing local MATLAB PLUGING root-folder, set in main

...project.paths.script.common_scripts              % B4:
...project.paths.script.eeg_tools                   % B5:
...project.paths.script.project                     % B6:

% set by define_paths_structure
...project.paths.global_scripts                     % B7:
...project.paths.global_spm_templates               % B8:

% set by: define_paths_structure
project.paths.project='';                           % B9:   folder containing data, epochs, results etc...(not scripts)
project.paths.original_data='';                     % B10:  folder containing EEG raw data (BDF, vhdr, eeg, etc...)
project.paths.input_epochs='';                      % B11:  folder containing EEGLAB EEG input epochs set files 
project.paths.output_epochs='';                     % B12:  folder containing EEGLAB EEG output condition epochs set files
project.paths.results='';                           % B13:  folder containing statistical results
project.paths.emg_epochs='';                        % B14:  folder containing EEGLAB EMG epochs set files 
project.paths.emg_epochs_mat='';                    % B15:  folder containing EMG data strucuture
project.paths.tf='';                                % B16:  folder containing 
project.paths.cluster_projection_erp='';            % B17:  folder containing 
project.paths.batches='';                           % B18:  folder containing bash batches (usually for SPM analysis)
project.paths.spmsources='';                        % B19:  folder containing sources images exported by brainstorm
project.paths.spmstats='';                          % B20:  folder containing spm stat files
project.paths.spm='';                               % B21:  folder containing spm toolbox
project.paths.eeglab='';                            % B22:  folder containing eeglab toolbox
project.paths.brainstorm='';                        % B23:  folder containing brainstorm toolbox

%% ======================================================================================================
% C:    TASK
% ======================================================================================================
project.task.events.start_experiment_trigger_value  = 1;    % C1:   signal experiment start
project.task.events.pause_trigger_value             = 2;    % C2:   start: pause, feedback and rest period
project.task.events.resume_trigger_value            = 3;    % C3:   end: pause, feedback and rest period
project.task.events.end_experiment_trigger_value    = 4;    % C4:   signal experiment end

project.task.events.baseline_start_trigger_value    = '9';
project.task.events.baseline_end_trigger_value      = '10';
project.task.events.trial_start_trigger_value       = project.task.events.baseline_start_trigger_value;
project.task.events.trial_end_trigger_value         = '5';

project.task.events.mrkcode_cond                    = { ...
                                                        {'11' '12' '13' '14' '15' '16'};...     % G15:  triggers defining conditions...even if only one trigger is used for each condition, a cell matrix is used
                                                        {'21' '22' '23' '24' '25' '26'};...            
                                                        {'31' '32' '33' '34' '35' '36'};...
                                                        {'41' '42' '43' '44' '45' '46'};...  
                                                     };
                                                 
project.task.events.valid_marker                    = [project.task.events.mrkcode_cond{1:length(project.task.events.mrkcode_cond)}];
project.task.events.import_marker                   = [{'1' '2' '3' '4' '5' '6' '7' '8' '9' '10'} project.task.events.valid_marker];  
                                                 
%% ======================================================================================================
% D:    IMPORT
% ======================================================================================================
% input file name  = [original_data_prefix subj_name original_data_suffix . original_data_extension]
% output file name = [original_data_prefix subj_name original_data_suffix project.import.output_suffix . set]

% input
project.import.acquisition_system       = 'BIOSEMI';                       % D1:   EEG hardware type: BIOSEMI | BRAINAMP
project.import.original_data_extension  = 'bdf';                           % D2:   original data file extension BDF | vhdr
project.import.original_data_folder     = '';                              % D3:   original data file subfolder
project.import.original_data_suffix     = '';                              % D4:   string after subject name in original EEG file name....often empty
project.import.original_data_prefix     = '';                              % D5:   string before subject name in original EEG file name....often empty

% do_import_collect
% possibilità di caricare diversi file per ogni soggetto e marcare i
% trigger di ogni file per distinguerli
project.import.file_label = {};

project.import.file_match = {};



% output
project.import.output_folder            = project.import.original_data_folder;  % D6:   string appended to fullfile(project.paths.project,'epochs', ...) , determining where to write imported file, by default coincides with original_data_folder
project.import.output_suffix            = '';                           % D7:   string appended to input file name after importing original file
project.import.emg_output_postfix       = [];                  			% D8:   string appended to input file name to EMG file

project.import.reference_channels       = {'CAR'};                      % D9:   list of electrodes to be used as reference: []: no referencing, {'CAR'}: CAR ref, {'el1', 'el2'}: used those electrodes

% D10:   list of electrodes to transform
project.import.ch2transform            = []; %no channel transformation

% project.import.ch2transform(1)          = struct('type', 'emg' , 'ch1', 28,'ch2', 32, 'new_label', 'bAPB');         ... emg bipolar                   
% project.import.ch2transform(2)          = struct('type', 'emg' , 'ch1', 43,'ch2', [], 'new_label', 'APB2');         ... emg monopolar
% project.import.ch2transform(3)          = struct('type', []    , 'ch1', 7,'ch2' , [], 'new_label', []);             ... discarded 
% project.import.ch2transform(4)          = struct('type', 'eog' , 'ch1', 53,'ch2', 54, 'new_label', 'hEOG');         ... eog bipolar
% project.import.ch2transform(5)          = struct('type', 'eog' , 'ch1', 55,'ch2', [], 'new_label', 'vEOG');         ... eog monopolar

% D11:  list of trigger marker to import. can be a cel array, or a string with these values: 'all', 'stimuli','responses'
project.import.valid_marker             = 'all';  

% montaggio standard per uniformare i file edf (e.g esportati dalla clinica
% con operatori creativi) in modo da avere tra file diversi gli stessi
% canali (merge dei cell array sottostanti) con lo stesso ordine
% (alfabetico)
project.import.montage_list = {...   
    {'Fp1','Fp2','F7','F3','Fz','F4','F8','FC5','FC1','FC2','FC6','T7','C3','Cz',...
    'C4','T8','TP9','CP5','CP1','CP2','CP6','TP10','P7','P3','Pz','P4','P8',...
    'O1','Oz','O2','AF7','AF3','AF4','AF8','F5','F1','F2','F6','FT9','FT7',...
    'FC3','FC4','FT8','FT10','C5','C1','C2','C6','TP7','CP3','CPz','CP4',...
    'TP8','P5','P1','P2','P6','PO7','PO3','POz','PO4','PO8'};
    {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5',...
    'T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9','PO7','PO3','O1','Iz','Oz',...
    'POz','Pz','CPz','Fpz','Fp2','AF8','AF4','AFz','Fz','F2','F4','F6','F8','FT8','FC6',...
    'FC4','FC2','FCz','Cz','C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6',...
    'P8','P10','PO8','PO4','O2'};
    {  'Fp1',    'Fp2',    'F3',    'F4',    'F7',    'F8',    'T3',    'T4',  'T5',...
    'T6',    'C3',    'C4',    'P3' ,   'P4',    'O1',    'O2',    'Fz',  'Cz',    ...
    'Pz'};
};

complete_montage = unique([project.import.montage_list{:}]);
tot_ch = length(complete_montage);






%% INTERPOLATE SEGMENTS OF DATA AROUND SELECTED TRIGGERS (E.G. ELECTROSTIMULATOR)
project.interpolate_segments.list_trigger_artifact = project.task.events.valid_marker  ;
project.interpolate_segments.cutlimits=[-2, 8];% limits of the segment to remove expressed in ms
project.interpolate_segments.window_smooth=[-4, 6];
project.interpolate_segments.method_smooth='moving';
project.interpolate_segments.n_smooth=5;



% enable filtering in import 
% GLOBAL FILTER 
project.import.do_global_bandpass      = 0; 
% NOTCH
project.import.do_global_notch      = 0;  


%% TESTART
% All-in-one function for artifact removal, including ASR.
% [EEG,HP,BUR] = clean_artifacts(EEG, Options...)
%
% This function removes flatline channels, low-frequency drifts, noisy channels, short-time bursts
% and incompletely repaird segments from the data. Tip: Any of the core parameters can also be
% passed in as [] to use the respective default of the underlying functions, or as 'off' to disable
% it entirely.
%
% Hopefully parameter tuning should be the exception when using this function -- however, there are
% 3 parameters governing how aggressively bad channels, bursts, and irrecoverable time windows are
% being removed, plus several detail parameters that only need tuning under special circumstances.
%
% Notes: 
%  * This function uses the Signal Processing toolbox for pre- and post-processing of the data
%    (removing drifts, channels and time windows); the core ASR method (clean_asr) does not require 
%    this toolbox but you will need high-pass filtered data if you use it directly.
%  * By default this function will identify subsets of clean data from the given recording to
%    enhance the robustness of the ASR calibration phase to strongly contaminated data; this uses
%    the Statistics toolbox, but can be skipped/bypassed if needed (see documentation).
%
% In:
%   EEG : Raw continuous EEG recording to clean up (as EEGLAB dataset structure).
%
%
%   NOTE: The following parameters are the core parameters of the cleaning procedure; they should be
%   passed in as Name-Value Pairs. If the method removes too many (or too few) channels, time
%   windows, or general high-amplitude ("burst") artifacts, you will want to tune these values.
%   Hopefully you only need to do this in rare cases.
%
%   ChannelCriterion : Minimum channel correlation. If a channel is correlated at less than this
%                      value to an estimate based on other channels, it is considered abnormal in
%                      the given time window. This method requires that channel locations are
%                      available and roughly correct; otherwise a fallback criterion will be used.
%                      (default: 0.85)
%
%   LineNoiseCriterion : If a channel has more line noise relative to its signal than this value, in
%                        standard deviations based on the total channel population, it is considered
%                        abnormal. (default: 4)
%
%   BurstCriterion : Standard deviation cutoff for removal of bursts (via ASR). Data portions whose
%                    variance is larger than this threshold relative to the calibration data are
%                    considered missing data and will be removed. The most aggressive value that can
%                    be used without losing much EEG is 3. For new users it is recommended to at
%                    first visually inspect the difference between the original and cleaned data to
%                    get a sense of the removed content at various levels. A quite conservative
%                    value is 5. Default: 5.
%
%   WindowCriterion : Criterion for removing time windows that were not repaired completely. This may
%                     happen if the artifact in a window was composed of too many simultaneous
%                     uncorrelated sources (for example, extreme movements such as jumps). This is
%                     the maximum fraction of contaminated channels that are tolerated in the final
%                     output data for each considered window. Generally a lower value makes the
%                     criterion more aggressive. Default: 0.25. Reasonable range: 0.05 (very
%                     aggressive) to 0.3 (very lax).
%
%   Highpass : Transition band for the initial high-pass filter in Hz. This is formatted as
%              [transition-start, transition-end]. Default: [0.25 0.75].
%
%   NOTE: The following are detail parameters that may be tuned if one of the criteria does
%   not seem to be doing the right thing. These basically amount to side assumptions about the
%   data that usually do not change much across recordings, but sometimes do.
%
%   ChannelCriterionMaxBadTime : This is the maximum tolerated fraction of the recording duration 
%                                during which a channel may be flagged as "bad" without being
%                                removed altogether. Generally a lower (shorter) value makes the
%                                criterion more aggresive. Reasonable range: 0.15 (very aggressive)
%                                to 0.6 (very lax). Default: 0.5.
%
%   BurstCriterionRefMaxBadChns: If a number is passed in here, the ASR method will be calibrated based 
%                                on sufficiently clean data that is extracted first from the
%                                recording that is then processed with ASR. This number is the
%                                maximum tolerated fraction of "bad" channels within a given time
%                                window of the recording that is considered acceptable for use as
%                                calibration data. Any data windows within the tolerance range are
%                                then used for calibrating the threshold statistics. Instead of a
%                                number one may also directly pass in a data set that contains
%                                calibration data (for example a minute of resting EEG).
%
%                                If this is set to 'off', all data is used for calibration. This will 
%                                work as long as the fraction of contaminated data is lower than the
%                                the breakdown point of the robust statistics in the ASR
%                                calibration (50%, where 30% of clearly recognizable artifacts is a
%                                better estimate of the practical breakdown point).
%
%                                A lower value makes this criterion more aggressive. Reasonable
%                                range: 0.05 (very aggressive) to 0.3 (quite lax). If you have lots
%                                of little glitches in a few channels that don't get entirely
%                                cleaned you might want to reduce this number so that they don't go
%                                into the calibration data. Default: 0.075.
%
%   BurstCriterionRefTolerances : These are the power tolerances outside of which a channel in a
%                                 given time window is considered "bad", in standard deviations
%                                 relative to a robust EEG power distribution (lower and upper
%                                 bound). Together with the previous parameter this determines how
%                                 ASR calibration data is be extracted from a recording. Can also be
%                                 specified as 'off' to achieve the same effect as in the previous
%                                 parameter. Default: [-Inf 5.5].
%
%   BurstRejection : 'on' or 'off'. If 'on' reject portions of data containing burst instead of 
%                    correcting them using ASR. Default is 'off'.
%
%   WindowCriterionTolerances : These are the power tolerances outside of which a channel in the final
%                               output data is considered "bad", in standard deviations relative
%                               to a robust EEG power distribution (lower and upper bound). Any time
%                               window in the final (repaired) output which has more than the
%                               tolerated fraction (set by the WindowCriterion parameter) of channel
%                               with a power outside of this range will be considered incompletely 
%                               repaired and will be removed from the output. This last stage can be
%                               skipped either by setting the WindowCriterion to 'off' or by taking
%                               the third output of this processing function (which does not include
%                               the last stage). Default: [-Inf 7].
%
%   FlatlineCriterion : Maximum tolerated flatline duration. In seconds. If a channel has a longer
%                       flatline than this, it will be considered abnormal. Default: 5
%
%   NoLocsChannelCriterion : Criterion for removing bad channels when no channel locations are
%                            present. This is a minimum correlation value that a given channel must
%                            have w.r.t. a fraction of other channels. A higher value makes the
%                            criterion more aggressive. Reasonable range: 0.4 (very lax) - 0.6
%                            (quite aggressive). Default: 0.45.
%
%   NoLocsChannelCriterionExcluded : The fraction of channels that must be sufficiently correlated with
%                                    a given channel for it to be considered "good" in a given time
%                                    window. Applies only to the NoLocsChannelCriterion. This adds
%                                    robustness against pairs of channels that are shorted or other
%                                    that are disconnected but record the same noise process.
%                                    Reasonable range: 0.1 (fairly lax) to 0.3 (very aggressive);
%                                    note that increasing this value requires the ChannelCriterion
%                                    to be relaxed in order to maintain the same overall amount of
%                                    removed channels. Default: 0.1.
%
%   MaxMem : The maximum amount of memory in MB used by the algorithm when processing. 
%            See function asr_processf for more information. Default is 64.
%
% Out:
%   EEG : Final cleaned EEG recording.
%
%   HP : Optionally just the high-pass filtered data.
%
%   BUR : Optionally the data without final removal of "irrecoverable" windows.
%
% Examples:
%   % Load a recording, clean it, and visualize the difference (using the defaults)
%   raw = pop_loadset(...);
%   clean = clean_artifacts(raw);
%   vis_artifacts(clean,raw);
%
%   % Use a more aggressive threshold (passing the parameters in by position)
%   raw = pop_loadset(...);
%   clean = clean_artifacts(raw,[],2.5);
%   vis_artifacts(clean,raw);
%
%   % Passing some parameter by name (here making the WindowCriterion setting less picky)
%   raw = pop_loadset(...);
%   clean = clean_artifacts(raw,'WindowCriterion',0.25);
%
%   % Disabling the WindowCriterion and ChannelCriterion altogether
%   raw = pop_loadset(...);
%   clean = clean_artifacts(raw,'WindowCriterion','off','ChannelCriterion','off');

project.testart.FlatlineCriterion = 4;          % 'off' disable
project.testart.Highpass = 'off';               % 'off' disable
project.testart.ChannelCriterion = 0.85;        % 'off' disable
project.testart.LineNoiseCriterion = 4;         % 'off' disable
project.testart.BurstCriterion = 5;             % 'off' disable
project.testart.WindowCriterion = 'off';        % 'off' disable
project.testart.BurstRejection = 'off';         % 'off' disable
project.testart.interpolate_channels = 'off';   % 'off' disable

%% ======================================================================================================
% E:    FINAL EEGDATA
% ======================================================================================================
project.eegdata.nch                         = 66;                           % E1:   final channels_number after electrode removal and polygraphic transformation eg for 64 eeg + 2 eog it is 66 in the final file 
project.eegdata.nch_eeg                     = 64;                           % E2:   EEG channels_number
project.eegdata.fs                          = 256;                          % E3:   final sampling frequency in Hz, if original is higher, then downsample it during pre-processing
project.eegdata.eeglab_channels_file_name   = 'standard-10-5-cap385.elp';   % E4:   universal channels file name containing the position of 385 channels
project.eegdata.eeglab_channels_file_path   = '';                           % E5:   later set by define_paths
    
project.eegdata.eeg_channels_list           = [1:project.eegdata.nch_eeg];  % E6:   list of EEG channels IDs

project.eegdata.emg_channels_list           = [];
project.eegdata.emg_channels_list_labels    = [];
project.eegdata.eog_channels_list           = [];
project.eegdata.eog_channels_list_labels    = [];

id_nextch=project.eegdata.nch_eeg;
for ch_id=1:length(project.import.ch2transform)
    ch = project.import.ch2transform(ch_id);
    if ~isempty(ch.new_label)
        id_nextch=id_nextch+1;
        if strcmp(ch.type, 'emg')
            project.eegdata.emg_channels_list           = [project.eegdata.emg_channels_list (id_nextch)];
            project.eegdata.emg_channels_list_labels    = [project.eegdata.emg_channels_list_labels ch.new_label];
        elseif strcmp(ch.type, 'eog')
            project.eegdata.eog_channels_list           = [project.eegdata.eog_channels_list (id_nextch)];
            project.eegdata.eog_channels_list_labels    = [project.eegdata.eog_channels_list_labels ch.new_label];
        end
    end
end

project.eegdata.no_eeg_channels_list = [project.eegdata.emg_channels_list project.eegdata.eog_channels_list];  % D10:  list of NO-EEG channels IDs

%% ======================================================================================================
% F:    PREPROCESSING
% ======================================================================================================
% input file name  = [original_data_prefix subj_name original_data_suffix project.import.output_suffix . set]
% output file name = [original_data_prefix subj_name original_data_suffix project.import.output_suffix . set]

% during import
project.preproc.output_folder   = project.import.output_folder;     % F1:   string appended to fullfile(project.paths.project,'epochs', ...) , determining where to write imported file



% enable filtering in preproc
%notch
project.preproc.do_global_notch      = 1;  
%bandpass
project.preproc.do_global_bandpass = 0;
project.preproc.do_specific_bandpass = 1;




% FILTER ALGORITHM (FOR ALL FILTERS IN THE PROJECT)
% the _12 suffix indicate filetrs of EEGLab 12; the _13 suffix indicate filetrs of EEGLab 13
project.filter.filter_algorithm = 'pop_basicfilter';%'pop_eegfiltnew_12';     % F2:   
    % * 'pop_eegfiltnew_12'                     = pop_eegfiltnew without the causal/non-causal option. is the default filter of EEGLab, 
    %                                             allows to set the band also for notch, so it's more flexible than pop_basicfilter of erplab 
    % * 'pop_basicfilter'                       = erplab filters (version erplab_1.0.0.33: more recent presented many bugs)  
    % * 'causal_pop_iirfilt_12'                 = causal version of iirfilt
    % * 'noncausal_pop_iirfilt_12'              = noncausal version of iirfilt
    % * 'causal_pop_eegfilt_12'                 = causal pop_eegfilt (old version of EEGLab filters)
    % * 'noncausal_pop_eegfilt_12'              = noncausal pop_eegfilt
    % * 'causal_pop_eegfiltnew_13'              = causal pop_eegfiltnew
    % * 'noncausal_pop_eegfiltnew_13'           = noncausal pop_eegfiltnew

% GLOBAL FILTER
project.filter.ff1_global    = 0.16;                       % F3:   lower frequency in Hz of the preliminar filtering applied during data import
project.filter.ff2_global    = 100;                        % F4:   higher frequency in Hz of the preliminar filtering applied during data import

%NOTCH
project.filter.notch_fcenter = 50;                         % F6:   center frequency of the notch filter 50 Hz or 60 Hz
project.filter.notch_fspan   = 5;                          % F7:   halved frequency range of the notch filters  
project.filter.notch_remove_armonics = 'first';            % F8:   'all' | 'first' reemove all or only the first harmonic(s) of the line current
% during pre-processing
%FURTHER EEG FILTER
project.filter.ff1_eeg     = 0.16;                         % F9:   lower frequency in Hz of the EEG filtering applied during filteressing
project.filter.ff2_eeg     = 100;                           % F10:  higher frequency in Hz of the EEG filtering applied during filteressing

%FURTHER EOG FILTER
project.filter.ff1_eog     = 0.16;                         % F11:  lower frequency in Hz of the EOG filtering applied during preprocessing
project.filter.ff2_eog     = 10;                            % F12:  higher frequency in Hz of the EEG filtering applied during preprocessing

%FURTHER EMG FILTER
project.filter.ff1_emg     = 5;                            % F13:   lower frequency in Hz of the EMG filtering applied during preprocessing
project.filter.ff2_emg     = 100;                          % F14:   higher frequency in Hz of the EMG filtering applied during preprocessing


% % FILTER ALGORITHM (FOR ALL FILTERS IN THE PROJECT)
% % the _12 suffix indicate filetrs of EEGLab 12; the _13 suffix indicate filetrs of EEGLab 13
% project.preproc.filter_algorithm = 'pop_basicfilter';     % F2:   
%     % * 'pop_eegfiltnew_12'                     = pop_eegfiltnew without the causal/non-causal option. is the default filter of EEGLab, 
%     %                                             allows to set the band also for notch, so it's more flexible than pop_basicfilter of erplab 
%     % * 'pop_basicfilter'                       = erplab filters (best solution)  
%     % * 'causal_pop_iirfilt_12'                 = causal version of iirfilt
%     % * 'noncausal_pop_iirfilt_12'              = noncausal version of iirfilt
%     % * 'causal_pop_eegfilt_12'                 = causal pop_eegfilt (old version of EEGLab filters)
%     % * 'noncausal_pop_eegfilt_12'              = noncausal pop_eegfilt
%     % * 'causal_pop_eegfiltnew_13'              = causal pop_eegfiltnew
%     % * 'noncausal_pop_eegfiltnew_13'           = noncausal pop_eegfiltnew
% 
% % GLOBAL FILTER
% project.preproc.ff1_global    = 0.16;                       % F3:   lower frequency in Hz of the preliminar filtering applied during data import
% project.preproc.ff2_global    = 100;                        % F4:   higher frequency in Hz of the preliminar filtering applied during data import
% 
% % NOTCH
% project.preproc.do_notch      = 1;                          % F5:   define if apply the notch filter at 50 Hz
% project.preproc.notch_fcenter = 50;                         % F6:   center frequency of the notch filter 50 Hz or 60 Hz
% project.preproc.notch_fspan   = 5;                          % F7:   halved frequency range of the notch filters  
% project.preproc.notch_remove_armonics = 'first';            % F8:   'all' | 'first' reemove all or only the first harmonic(s) of the line current
% % during pre-processing
% %FURTHER EEG FILTER
% project.preproc.ff1_eeg     = 0.16;                         % F9:   lower frequency in Hz of the EEG filtering applied during preprocessing
% project.preproc.ff2_eeg     = 45;                           % F10:  higher frequency in Hz of the EEG filtering applied during preprocessing
% 
% %FURTHER EOG FILTER
% project.preproc.ff1_eog     = 0.16;                         % F11:  lower frequency in Hz of the EOG filtering applied during preprocessing
% project.preproc.ff2_eog     = 8;                            % F12:  higher frequency in Hz of the EEG filtering applied during preprocessing
% 
% %FURTHER EMG FILTER
% project.preproc.ff1_emg     = 5;                            % F13:   lower frequency in Hz of the EMG filtering applied during preprocessing
% project.preproc.ff2_emg     = 100;                          % F14:   higher frequency in Hz of the EMG filtering applied during preprocessing







% CALCULATE RT
project.preproc.rt.eve1_type                = 'eve1_type';  % F15:
project.preproc.rt.eve2_type                = 'eve2_type';  % F16:
project.preproc.rt.allowed_tw_ms.min        = [];           % F17:
project.preproc.rt.allowed_tw_ms.max        = [];           % F18:
project.preproc.rt.output_folder            = [];           % F19:

% UNIFORM MONTAGES
project.preproc.montage_list = {...
                                {'Fp1','Fp2','F7','F3','Fz','F4','F8','FC5','FC1','FC2','FC6','T7','C3','Cz',...
                                'C4','T8','TP9','CP5','CP1','CP2','CP6','TP10','P7','P3','Pz','P4','P8',...
                                'O1','Oz','O2','AF7','AF3','AF4','AF8','F5','F1','F2','F6','FT9','FT7',...
                                'FC3','FC4','FT8','FT10','C5','C1','C2','C6','TP7','CP3','CPz','CP4',...
                                'TP8','P5','P1','P2','P6','PO7','PO3','POz','PO4','PO8'};                                
                                {'Fp1','AF7','AF3','F1','F3','F5','F7','FT7','FC5','FC3','FC1','C1','C3','C5',...
                                 'T7','TP7','CP5','CP3','CP1','P1','P3','P5','P7','P9','PO7','PO3','O1','Iz','Oz',...
                                 'POz','Pz','CPz','Fpz','Fp2','AF8','AF4','AFz','Fz','F2','F4','F6','F8','FT8','FC6',...
                                 'FC4','FC2','FCz','Cz','C2','C4','C6','T8','TP8','CP6','CP4','CP2','P2','P4','P6',...
                                 'P8','P10','PO8','PO4','O2'};
                                {'E1', 'E2', 'E3', 'E4', 'E5', 'E6', 'E7', 'E8', 'E9', 'E10', 'E11', 'E12', 'E13', ...
                                 'E14', 'E15', 'E16', 'E17', 'E18', 'E19', 'E20', 'E21', 'E22', 'E23', 'E24', 'E25', ...
                                 'E26', 'E27', 'E28', 'E29', 'E30', 'E31', 'E32', 'E33', 'E34', 'E35', 'E36', 'E37', ...
                                 'E38', 'E39', 'E40', 'E41', 'E42', 'E43', 'E44', 'E45', 'E46', 'E47', 'E48', 'E49', ...
                                 'E50', 'E51', 'E52', 'E53', 'E54', 'E55', 'E56', 'E57', 'E58', 'E59', 'E60', 'E61', ...
                                 'E62', 'E63', 'E64', 'E65', 'E66', 'E67', 'E68', 'E69', 'E70', 'E71', 'E72', 'E73', ...
                                 'E74', 'E75', 'E76', 'E77', 'E78', 'E79', 'E80', 'E81', 'E82', 'E83', 'E84', 'E85', ...
                                 'E86', 'E87', 'E88', 'E89', 'E90', 'E91', 'E92', 'E93', 'E94', 'E95', 'E96', 'E97', ...
                                 'E98', 'E99', 'E100', 'E101', 'E102', 'E103', 'E104', 'E105', 'E106', 'E107', 'E108', ...
                                 'E109', 'E110', 'E111', 'E112', 'E113', 'E114', 'E115', 'E116', 'E117', 'E118', 'E119', ...
                                 'E120', 'E121', 'E122', 'E123', 'E124', 'E125', 'E126', 'E127', 'E128', 'Cz'}
};


project.preproc.montage_names = { 'BRAINAMP','BIOSEMI','GEODESIC'};

project.preproc.interpolate_channels = 'off';   % 'off' disable

                                                                                               
% INSERT BLOCK MARKERS (only if
% project.preproc.insert_end_trial.end_trial_marker_type is non empty)
project.preproc.insert_block.trials_per_block                           = 40;              % number denoting the number of trials per block  
                      
     

%% ADD NEW MARKERS

% DEFINE MARKER LABELS
project.preproc.marker_type.begin_trial     = 't1';
project.preproc.marker_type.end_trial       = 't2';
project.preproc.marker_type.begin_baseline  = 'b1';
project.preproc.marker_type.end_baseline    = 'b2';

% INSERT BEGIN TRIAL MARKERS (only if both the target and the begin trial
% types are NOT empty)
project.preproc.insert_begin_trial.target_event_types       = {'b1'};        % if it is empty, no begin trial is inserted. string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the begin trial markers 
project.preproc.insert_begin_trial.delay.s                  = [0];           % array with the same length of project.preproc.insert_end_trial.target_event_types: for each target type time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new begin trial markers
                                                                                                

% INSERT END TRIAL MARKERS (only if both the target and the begin trial
% types are NOT empty)
project.preproc.insert_end_trial.target_event_types         = {'b1'};        % if it is empty, no end trial is inserted.string or cell array of strings denoting the type(s) (i.e. labels) of the target events used to set the the end trial markers 
project.preproc.insert_end_trial.delay.s                    = [2.5];         % array with the same length of project.preproc.insert_end_trial.target_event_types: for each target type time shift (in ms) to anticipate (negative values ) or posticipate (positive values) the new end trial markers


% INSERT BEGIN BASELINE MARKERS (project.epoching.baseline_replace.baseline_begin_marker)
project.preproc.insert_begin_baseline.target_event_types    = {'S 20'};      % a target event for placing the baseline markers: baseline begin marker will be placed at the target marker with a selected delay.
project.preproc.insert_begin_baseline.delay.s               = [-0.5];        % array with the same length of project.preproc.insert_begin_baseline.target_event_types: for each target type the delay (in seconds) between the target marker and the begin baseline marker to be placed: 
                                                                                                                        % >0 means that baseline begin FOLLOWS the target, 
                                                                                                                        % =0 means that baseline begin IS AT THE SAME TIME the target, 
                                                                                                                        % <0 means that baseline begin ANTICIPATES the target.
                                                                                                                        % IMPOTANT NOTE: The latency information is displayed in seconds for continuous data, 
                                                                                                                        % or in milliseconds relative to the epoch's time-locking event for epoched data. 
                                                                                                                        % As we will see in the event scripting section, 
                                                                                                                        % the latency information is stored internally in data samples (points or EEGLAB 'pnts') 
                                                                                                                        % relative to the beginning of the continuous data matrix (EEG.data). 

% INSERT END BASELINE MARKERS (project.epoching.baseline_replace.baseline_end_marker)                                                                                                                        
project.preproc.insert_end_baseline.target_event_types      = {'S 20'};           % a target event for placing the baseline markers: baseline begin marker will be placed at the target marker with a selected delay.
project.preproc.insert_end_baseline.delay.s                 = [0];                % array with the same length of project.preproc.insert_end_baseline.target_event_types: for each target type the delay (in seconds) between the target marker and the begin baseline marker to be placed: 
                                                                                                                        % >0 means that baseline begin FOLLOWS the target, 
                                                                                                                        % =0 means that baseline begin IS AT THE SAME TIME the target, 
                                                                                                                        % <0 means that baseline begin ANTICIPATES the target.
                                                                                                                        % IMPOTANT NOTE: The latency information is displayed in seconds for continuous data, 
                                                                                                                        % or in milliseconds relative to the epoch's time-locking event for epoched data. 
                                                                                                                        % As we will see in the event scripting section, 
                                                                                                                       
%% ICA
project.ica.ica_type = 'runica';%'binica';
project.ica.do_pca = 0;
project.ica.do_subsample = 0;
project.ica.ica_sr = 125; % deve essere almeno il doppio della max frequenza che si vuole scomporre con l'ica ma e' meglio che sia un divisore della frequenza di campionamento iniziale

% the latency information is stored internally in data samples (points or EEGLAB 'pnts')
% relative to the beginning of the continuous data matrix (EEG.data).

                                                                                           
%% ======================================================================================================
% G:    EPOCHING
% =======================================================================================================
% input file name  = [original_data_prefix subj_name original_data_suffix project.import.output_suffix epoching.input_suffix . set]
% output file name = [original_data_prefix subj_name original_data_suffix project.import.output_suffix epoching.input_suffix '_' CONDXX. set]





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

project.epoching.baseline_replace.mode                       = 'trial';                      % replace a baseline before/after events to  be epoched and processed: 
                                                                                                %  * 'trial'    use a baseline within each trial
                                                                                                %  * 'external' use a baseline obtained from a period of global baseline, not within the trials, 
                                                                                                %     extracted from the current recording or from another file
                                                                                                %  * 'none'do not add a baseline (standard simple case)    


project.epoching.baseline_replace.baseline_originalposition  = 'before';                     % when replace the new baseline: the baseline segments to be inserted are originally 'before' or 'after' the events to  be epoched and processed                                                                                                                                                                             
project.epoching.baseline_replace.baseline_finalposition     = 'before';                     % when replace the new baseline: the baseline segments are inserted 'before' or 'after' the events to  be epoched and processed                                                                                 
project.epoching.baseline_replace.replace                    = 'part';                    % 'all' 'part' replace all the pre/post marker period with a replicated baseline or replace the baseline at the begin (final position 'before') or at the end (final position 'after') of the recostructed baseline

                                                                                                             

% EEG
project.epoching.input_suffix           = '_mc';                        % G1:   final file name before epoching : default is '_raw_mc'
project.epoching.input_folder           = project.preproc.output_folder;% G2:   input epoch folder, by default the preprocessing output folder
project.epoching.bc_type                = 'event';                     % G3:   type of baseline correction: global: considering all the trials, 'condition': by condition, 'event': event-by-event

project.epoching.epo_st.s               = -0.99;                        % G4:   EEG epochs start latency
project.epoching.epo_end.s              = 3;                            % G5:   EEG epochs end latency
project.epoching.bc_st.s                = -0.9;                         % G6:   EEG baseline correction start latency
project.epoching.bc_end.s               = -0.512;                       % G7:   EEG baseline correction end latency
project.epoching.baseline_duration.s    = project.epoching.bc_end.s - project.epoching.bc_st.s ;

% point
project.epoching.bc_st_point            = round((project.epoching.bc_st.s-project.epoching.epo_st.s)*project.eegdata.fs)+1;     % G7:   EEG baseline correction start point
project.epoching.bc_end_point           = round((project.epoching.bc_end.s-project.epoching.epo_st.s)*project.eegdata.fs)+1;    % G8:   EEG baseline correction end point

% EMG
project.epoching.emg_epo_st.s           = -0.99;                        % G9:   EMG epochs start latency
project.epoching.emg_epo_end.s          = 3;                            % G10:  EMG epochs end latency
project.epoching.emg_bc_st.s            = -0.9;                         % G11:  EMG baseline correction start latency
project.epoching.emg_bc_end.s           = -0.512;                       % G12:  EMG baseline correction end latency

% point
project.epoching.emg_bc_st_point        = round((project.epoching.emg_bc_st.s-project.epoching.emg_epo_st.s)*project.eegdata.fs)+1; % G13:   EMG baseline correction start point
project.epoching.emg_bc_end_point       = round((project.epoching.emg_bc_end.s-project.epoching.emg_epo_st.s)*project.eegdata.fs)+1; % G14:   EMG baseline correction end point

% markers

project.epoching.mrkcode_cond       = project.task.events.mrkcode_cond;
project.epoching.numcond            = length(project.epoching.mrkcode_cond);       % G16: conditions' number 
project.epoching.valid_marker       = [project.epoching.mrkcode_cond{1:length(project.epoching.mrkcode_cond)}];

project.epoching.condition_names={'control' 'AO' 'AOCS' 'AOIS'};        % G 17: conditions' labels
if length(project.epoching.condition_names) ~= project.epoching.numcond
    disp('ERROR in project_structure: number of conditions do not coincide !!! please verify')
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

if isfield(project, 'subjects')
    if isfield(project.subjects, 'data')
        project.subjects = rmfield(project.subjects, 'data');
    end
end

project.subjects.narrowband_file            = [];
project.subjects.baseline_file              = [];
project.subjects.baseline_file_interval_s   = [];

%% allow the possibility to define a different reference condition for each band
% project.subjects.narrowband_suffix_cell ={'baseline','ao','aois'}; 

project.subjects.data(1)  = struct('name', 'CC_01_vittoria', 'group', 'CC', 'age', 13, 'gender', 'f', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(2)  = struct('name', 'CC_02_fabio',    'group', 'CC', 'age', 12, 'gender', 'm', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(3)  = struct('name', 'CC_03_anna',     'group', 'CC', 'age', 12, 'gender', 'f', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(4)  = struct('name', 'CC_04_giacomo',  'group', 'CC', 'age', 8,  'gender', 'm', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(5)  = struct('name', 'CC_05_stefano',  'group', 'CC', 'age', 9,  'gender', 'm', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(6)  = struct('name', 'CC_06_giovanni', 'group', 'CC', 'age', 6,  'gender', 'm', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(7)  = struct('name', 'CC_07_davide',   'group', 'CC', 'age', 11, 'gender', 'm', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(8)  = struct('name', 'CC_08_jonathan', 'group', 'CC', 'age', 8,  'gender', 'm', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(9)  = struct('name', 'CC_09_antonella','group', 'CC', 'age', 9,  'gender', 'f', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(10) = struct('name', 'CC_10_chiara',   'group', 'CC', 'age', 11, 'gender', 'f', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);


project.subjects.data(11) = struct('name', 'CP_01_riccardo', 'group', 'CP', 'age', 6,  'gender', 'm', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(12) = struct('name', 'CP_02_ester',    'group', 'CP', 'age', 8,  'gender', 'f', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(13) = struct('name', 'CP_03_sara',     'group', 'CP', 'age', 11, 'gender', 'f', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(14) = struct('name', 'CP_04_matteo',   'group', 'CP', 'age', 10, 'gender', 'm', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(15) = struct('name', 'CP_05_gregorio', 'group', 'CP', 'age', 6,  'gender', 'm', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(16) = struct('name', 'CP_06_fernando', 'group', 'CP', 'age', 8,  'gender', 'm', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(17) = struct('name', 'CP_07_roberta',  'group', 'CP', 'age', 9,  'gender', 'f', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(18) = struct('name', 'CP_08_mattia',   'group', 'CP', 'age', 7,  'gender', 'm', 'handedness', 'r', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(19) = struct('name', 'CP_09_alessia',  'group', 'CP', 'age', 10, 'gender', 'f', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);
project.subjects.data(20) = struct('name', 'CP_10_livia',    'group', 'CP', 'age', 10, 'gender', 'm', 'handedness', 'l', 'bad_segm', [], 'bad_ch', [], 'bad_ic', [],'baseline_file',[],'baseline_file_interval_s',[],'frequency_bands_list',[]);


% bad segments (begin and end in sec) to be removed and interpolated (visual inspection, no asr) in the preprocessing (do_preproc)
project.subjects.data(16).bad_segm    = ...
{
    [...
    216157  216955;... 
    216157  216955;...
    218155  218959; ...
    ]
};


% bad channels to be removed and interpolated (visual inspection, no asr) in the preprocessing (do_preproc)
project.subjects.data(16).bad_ch    = {'P1'};
project.subjects.data(6).bad_ch     = {'PO3'};

% bad independent components to be removed in the preprocessing (do_remove_ica)
project.subjects.data(16).bad_ic    = {1,2,5};
project.subjects.data(6).bad_ic     = {1:3};


...project.subjects.data(1).frequency_bands_list = {[4,8];[5,9];[14,20];[20,32]};
...project.subjects.data(6).frequency_bands_list = {[4,8];[6,10];[14,20];[20,32]};


project.subjects.list               = {project.subjects.data.name};
project.subjects.numsubj            = length(project.subjects.list);

project.subjects.group_names        = {'CC', 'CP'};
project.subjects.groups             = {{'CC_01_vittoria', 'CC_02_fabio','CC_03_anna', 'CC_04_giacomo', 'CC_05_stefano', 'CC_06_giovanni', 'CC_07_davide', 'CC_08_jonathan', 'CC_09_antonella', 'CC_10_chiara'}; ...
                                      {'CP_01_riccardo', 'CP_02_ester', 'CP_03_sara', 'CP_04_matteo', 'CP_05_gregorio', 'CP_06_fernando', 'CP_07_roberta', 'CP_08_mattia', 'CP_09_alessia', 'CP_10_livia'} ...
                                      };
                                  
                                  
% structure containing subjects mean behavioral scores associated to each condition
% the 'data' field must contain a numeric matric of NSUBJ row and NCONDITIONS columns
% mind the conditions order !!!!, must match project.epoching.condition_names ones
project.subjects.conditions_behavioral_data(1) =  struct('name', 'RT', 'data', ... 
                                   [703.26,743.26,696.22,734.19; ...   nsubj x ncond
                                    550.59,545.40,523.53,536.05; ... 
                                    ]);

project.subjects.conditions_behavioral_data(2) =  struct('name', 'RT_RATIO', 'data', ...
                                   [1.057,1.057,1.055,1.055; ... 
                                    1.057,1.057,1.055,1.055; ... 
                                    ]);
      
                                
                                
%% AUTOMATIC MARK TO REMOVE BAD EPOCHS
project.mark_badepochs.eegthresh.lowthresh = -25;
project.mark_badepochs.eegthresh.upthresh  = 25;

project.mark_badepochs.rejtrend.maxslope  = 50;
project.mark_badepochs.rejtrend.minR      = 0.3;

project.mark_badepochs.rejkurt.locthresh  = 5;
project.mark_badepochs.rejkurt.globthresh = 5;

project.mark_badepochs.jointprob.locthresh  = 5;
project.mark_badepochs.jointprob.globthresh = 5;

                                
%% MICROSTATES
project.microstates.group_list = { 'AS', 'AEB'};

project.microstates.suffix = 'controlli';

project.microstates.cond_list = {{'s-s2-1sc-1tc','s-s2-1sc-1tl','s-s2-1sl-1tc','s-s2-1sl-1tl'};... % condizioni epocate dall'epoching
                                 {'t-s2-1sc-1tc','t-s2-1sc-1tl','t-s2-1sl-1tc','t-s2-1sl-1tl'};...
                                  {'s-s2-1sc-1tc','s-s2-1sc-1tl','s-s2-1sl-1tc','s-s2-1sl-1tl','t-s2-1sc-1tc','t-s2-1sc-1tl','t-s2-1sl-1tc','t-s2-1sl-1tl'};...
                                };

project.microstates.cond_names = {'space','time','space-time',};                            
project.microstates.micro_selectdata.datatype = 'ERPavg';
project.microstates.micro_selectdata.avgref = 0;
project.microstates.micro_selectdata.normalise = 1;

project.microstates.micro_segment.algorithm = 'taahc';
project.microstates.micro_segment.sorting = 'Global explained variance';
project.microstates.micro_segment.normalise = 1;
project.microstates.micro_segment.Nmicrostates = 3:8;
project.microstates.micro_segment.verbose = 1;
project.microstates.micro_segment.determinism = 1;
project.microstates.micro_segment.polarity = 1;

project.microstates.selectNmicro.Nmicro = 5;

project.microstates.micro_fit.polarity = 0;

project.microstates.micro_smooth.label_type ='segmentation';
project.microstates.micro_smooth.smooth_type ='reject segments';
project.microstates.micro_smooth.minTime =10;
project.microstates.micro_smooth.polarity =1;

project.microstates.micro_stats.label_type ='segmentation';
project.microstates.micro_stats.polarity =0;


project.microstates.MicroPlotSegments.label_type ='segmentation';
project.microstates.MicroPlotSegments.plotsegnos ='all';
project.microstates.MicroPlotSegments.plot_time =[];
project.microstates.MicroPlotSegments.plottopos =1;
project.microstates.MicroPlotSegments.plot_ylim = [-1,1];



% CALCULATE SUBJECT SPECTRA

project.subject_spectra.do_group             = 'off';

project.subject_spectra.freqrange            = [1,13];
project.subject_spectra.freq                 = 1:10;
project.subject_spectra.plotchans            = 1:tot_ch;
% project.subject_spectra.band_analysis.lim   = [0, 2; 2, 4; 4, 6; 6, 8;8, 10; 10, 12];
% project.subject_spectra.band_analysis.name   = {'delta1', 'delta2', 'theta1', 'theta2', 'alpha1', 'alpha2'};
% project.subject_spectra.band_analysis.caxis   = [-30, 30; -10, 10; -5, 5;-5, 5; -7, 7; -3, 3];
% 
project.subject_spectra.band_analysis.lim   = [0, 2; 2, 4; 4, 8; 8, 10; 10, 12];
project.subject_spectra.band_analysis.name   = {'delta1', 'delta2', 'theta', 'alpha1', 'alpha2'};
project.subject_spectra.band_analysis.caxis   = [-30, 30; -10, 10; -5, 5; -7, 7; -3, 3];
project.subject_spectra.ylim_rel               = [0,80];
project.subject_spectra.ylim_abs               = [];


% project.subject_spectra.roi_analysis.ch     =  {...
%     {'O1','Oz','O2'},.... 'Occipital'
%     {'T7'},...'T7'
%     {'T8'},...'T8'
%     {'POz','Pz','CPz'},...'Dorsal'
%     {'C3', 'C4'}, ... 'Tactile'
%     {'PO7','P5','P9'},... 'Left_ventral'
%     {'PO8','P6','P10'},...'Right_ventral'
%     {'Cz','C1','C2'},... 'Central_dorsal'
%     {'FCz','FC1','FC2'},... 'SMA'
%     {'Fz','F1','F2'},... 'Frontal_dorsal'
%     {'F5','F7','FT7'},...'Left_FT'
%     {'F6','F8','FT8'}...'Right_FT'
%     };
% project.subject_spectra.roi_analysis.name   =  {...
%     'Occipital',...
%     'T7',...
%     'T8',...
%     'Dorsal',...
%     'Tactile',...
%     'Left_ventral',...
%     'Right_ventral',...    
%     'Central_dorsal',...
%     'SMA',...
%     'Frontal_dorsal',...
%     'Left_FT',...
%     'Right_FT'};



project.subject_spectra.roi_analysis.ch     =  {...
    {'O1','Oz','O2'},.... 'Occipital'
    {'T7'},...'T7'
    {'T8'},...'T8'
    {'POz','Pz','CPz'},...'Dorsal'
    {'C3', 'C4'}, ... 'Tactile'
    {'PO7','P5','P9'},... 'Left_ventral'
    {'PO8','P6','P10'},...'Right_ventral'
    {'Cz','C1','C2'},... 'Central_dorsal'
    {'FCz','FC1','FC2'},... 'SMA'
    {'Fz','F1','F2'},... 'Frontal_dorsal'
    ...{'F5','F7','FT7'},...'Left_FT'
    ...{'F6','F8','FT8'}...'Right_FT'
    };
project.subject_spectra.roi_analysis.name   =  {...
    'Occipital',...
    'T7',...
    'T8',...
    'Dorsal',...
    'Tactile',...
    'Left_ventral',...
    'Right_ventral',...    
    'Central_dorsal',...
    'SMA',...
    'Frontal_dorsal',...
    ...'Left_FT',...
    ...'Right_FT'...
    };





% project.subject_spectra.agebin.lim   = [0, 2; 2, 5; 5, 11];
% project.subject_spectra.agebin.name   = {'[0-2)', '[2-5)', '[5-11)'};

% project.subject_spectra.agebin.lim   = [0,3; 3,6; 6,9; 9,11; ];
% project.subject_spectra.agebin.name   = {'[0-3)', '[3-6)','[6-9)','[9-11)'};

% project.subject_spectra.agebin.lim   = [0,2; 2,4; 4,6; 6,8; 8,11 ];
% project.subject_spectra.agebin.name   = {'[0-2)', '[2-4)','[4-6)','[6-8)','[8-11)'};

project.subject_spectra.agebin.lim   = [0,3; 3,6; 6,11 ];
project.subject_spectra.agebin.name   = {'[0-3)', '[3-6)','[6-11)'};


% project.subject_spectra.group        = {};


project.subject_spectra.scale           = 'raw'; %'raw'|'log'
project.subject_spectra.plot_single_subject           = 'on'; %'off'|'on'

project.subject_spectra.replot_folder           = 'C:\projects\mondino\results\subject_spectra_15-Apr-2019-12-48-09_raw\plot'; 
project.subject_spectra.analysis_name           = 'vexclin_vex0_vex_2'; 

                     

%% ======================================================================================================
% I:    STUDY
% ======================================================================================================
project.study.filename                          = [project.name project.study_suffix '.study'];

% structures that associates conditions file with (multiple) factor(s)

% IMPORTANT NOTE: as additional factors are added to the EEG.event
% structure as new fields, you cannot call the new factor names using
% mathematical operators, which are wrongly intrepretated by matlab. eg,
% replace the name 'condition-group' with 'condition_group' or
% 'conditionGroup' OR 'conditionXgroup'


if isfield(project, 'study')
    if isfield(project.study, 'factors')
        project.study = rmfield(project.study, 'factors');
    end
end

project.study.factors(1)                        = struct('factor', 'motion', 'file_match', [], 'level', 'translating');
project.study.factors(2)                        = struct('factor', 'motion', 'file_match', [], 'level', 'centered');
project.study.factors(3)                        = struct('factor', 'shape' , 'file_match', [], 'level', 'walker');
project.study.factors(4)                        = struct('factor', 'shape' , 'file_match', [], 'level', 'scrambled');

project.study.factors(1).file_match             = {'twalker', 'tscrambled'};
project.study.factors(2).file_match             = {'cwalker', 'cscrambled'};
project.study.factors(3).file_match             = {'twalker', 'cwalker'};
project.study.factors(4).file_match             = {'tscrambled', 'cscrambled'};

% ERP
project.study.erp.tmin_analysis.s               = project.epoching.epo_st.s;
project.study.erp.tmax_analysis.s               = project.epoching.epo_end.s;
project.study.erp.ts_analysis.s                 = 0.008;
project.study.erp.timeout_analysis_interval.s   = [project.study.erp.tmin_analysis.s:project.study.erp.ts_analysis.s:project.study.erp.tmax_analysis.s];

% ERSP
project.study.ersp.tmin_analysis.s              = project.epoching.epo_st.s;
project.study.ersp.tmax_analysis.s              = project.epoching.epo_end.s;
project.study.ersp.ts_analysis.s                = 0.01;
project.study.ersp.timeout_analysis_interval.s  = [project.study.ersp.tmin_analysis.s:project.study.ersp.ts_analysis.s:project.study.ersp.tmax_analysis.s];

project.study.ersp.fmin_analysis                = 4;
project.study.ersp.fmax_analysis                = 32;
project.study.ersp.fs_analysis                  = 0.5;
project.study.ersp.freqout_analysis_interval    = [project.study.ersp.fmin_analysis:project.study.ersp.fs_analysis:project.study.ersp.fmax_analysis];
project.study.ersp.padratio                     = 16;
project.study.ersp.cycles                       = 0; ...[3 0.8];
project.study.ersp.winsize                       = 32; ...128;  



project.study.precompute.recompute              = 'on';
project.study.precompute.do_erp                 = 'on';
project.study.precompute.do_ersp                = 'on';
project.study.precompute.do_erpim               = 'on';
project.study.precompute.do_spec                = 'on';

project.study.precompute.erp                    = {'interp','off','allcomps','on','erp'  ,'on','erpparams'  ,{},'recompute','off'};
project.study.precompute.erpim                  = {'interp','off','allcomps','on','erpim','on','erpimparams',{'nlines' 10 'smoothing' 10},'recompute','off'};
project.study.precompute.spec                   = {'interp','off','allcomps','on','spec' ,'on','specparams' ,{'specmode' 'fft','freqs' project.study.ersp.freqout_analysis_interval},'recompute','off'};
project.study.precompute.ersp                   = {'interp','off' ,'allcomps','on','ersp' ,'on','erspparams' ,{'cycles' project.study.ersp.cycles,  'freqs', project.study.ersp.freqout_analysis_interval, 'timesout', project.study.ersp.timeout_analysis_interval.s*1000, ...
                                                   'freqscale','linear','padratio',project.study.ersp.padratio, 'baseline',[project.epoching.bc_st.s*1000 project.epoching.bc_end.s*1000] , 'winsize',project.study.ersp.winsize},'itc','on','recompute','off'};


%% ======================================================================================================
% L:    DESIGN
% ======================================================================================================
if isfield(project, 'design')
    project = rmfield(project, 'design');
end

project.design(2)                   = struct('name',  'ao_control_ungrouped'   , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off', 'grouping_factor',[],'comparing_factor',[]);
project.design(3)                   = struct('name',  'aocs_control_ungrouped' , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(4)                   = struct('name',  'aocs_ao_ungrouped'      , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(5)                   = struct('name',  'aois_ao_ungrouped'      , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(6)                   = struct('name',  'aocs_aois_ungrouped'    , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(7)                   = struct('name',  'sound_effect_ungrouped' , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', ''       , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(8)                   = struct('name',  'ao_control'             , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(9)                   = struct('name',  'aocs_control'           , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(10)                  = struct('name', 'aocs_ao'                 , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(11)                  = struct('name', 'aois_ao'                 , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(12)                  = struct('name', 'aocs_aois'               , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');
project.design(13)                  = struct('name', 'sound_effect'            , 'factor1_name', 'condition', 'factor1_levels', [] , 'factor1_pairing', 'on', 'factor2_name', 'group'  , 'factor2_levels', [], 'factor2_pairing', 'off');

project.design(2).factor1_levels    = {'AO','control'};
project.design(3).factor1_levels    = {'AOCS','control'};
project.design(4).factor1_levels    = {'AOCS','AO'};
project.design(5).factor1_levels    = {'AOIS','AO'};
project.design(6).factor1_levels    = {'AOCS','AOIS'};
project.design(7).factor1_levels    = {'AOCS','AOIS','AO'};
project.design(8).factor1_levels    = {'AO','control'};
project.design(9).factor1_levels    = {'AOCS','control'};
project.design(10).factor1_levels   = {'AOCS','AO'};
project.design(11).factor1_levels   = {'AOIS','AO'};
project.design(12).factor1_levels   = {'AOCS','AOIS'};
project.design(13).factor1_levels   = {'AOCS','AOIS','AO'};

project.design(8).factor2_levels    = {'CC','CP'};
project.design(9).factor2_levels    = {'CC','CP'};
project.design(10).factor2_levels   = {'CC','CP'};
project.design(11).factor2_levels   = {'CC','CP'};
project.design(12).factor2_levels   = {'CC','CP'};
project.design(13).factor2_levels   = {'CC','CP'};

project.design(1).factor1_levels    = {'cwalker' 'twalker' 'cscrambled' 'tscrambled'};
project.design(2).factor1_levels    = {'centered','translating'};
project.design(3).factor1_levels    = {'scrambled','walker'};
project.design(4).factor1_levels    = {'scrambled','walker'};
project.design(4).factor2_levels    = {'centered','translating'};



  

%% ======================================================================================================
% N:   STATS + POSTPROCESS (to be fixed, project.stats.  and project.postprocess fields will be merged
% ======================================================================================================




% ===================================================
% ERP
% ===================================================

project.stats.erp.pvalue                        = 0.025; ...0.01;       % level of significance applied in ERP statistical analysis
project.stats.erp.num_permutations              = 3;                    % number of permutations applied in ERP statistical analysis
project.stats.erp.num_tails                     = 2;
project.stats.eeglab.erp.method                 = 'bootstrap';          % method applied in ERP statistical analysis
project.stats.eeglab.erp.correction             = 'fdr';                % multiple comparison correction applied in ERP statistical analysis

project.postprocess.erp.mode.continous              = struct('time_resolution_mode', 'continuous', 'peak_type', 'off'          , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
project.postprocess.erp.mode.tw_group_noalign       = struct('time_resolution_mode', 'tw'        , 'peak_type', 'group'        , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
project.postprocess.erp.mode.tw_group_align         = struct('time_resolution_mode', 'tw'        , 'peak_type', 'group'        , 'align', 'on',  'tw_stat_estimator', 'tw_extremum');
project.postprocess.erp.mode.tw_individual_noalign  = struct('time_resolution_mode', 'tw'        , 'peak_type', 'individual'   , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
project.postprocess.erp.mode.tw_individual_align    = struct('time_resolution_mode', 'tw'        , 'peak_type', 'individual'   , 'align', 'on' , 'tw_stat_estimator', 'tw_extremum');


project.postprocess.erp.sel_extrema='first_occurrence';%'avg_occurrences'


project.postprocess.erp.roi_list = {  ...
          {'F5','F7','AF7','FT7'};  ... left IFG
          {'F6','F8','AF8','FT8'};  ... right IFG
          {'FC3','FC5'};            ... l PMD
          {'FC4','FC6'};            ... r PMD    
          {'C3'};                   ... iM1 hand
          {'C4'};                   ... cM1 hand
          {'Cz'}

};
project.postprocess.erp.roi_names={'left-ifg','right-ifg','left-PMd','right-PMd','left-SM1','right-SM1','SMA'}; ...,'left-ipl','right-ipl','left-spl','right-spl','left-sts','right-sts','left-occipital','right-occipital'};
project.postprocess.erp.numroi=length(project.postprocess.erp.roi_list);


project.postprocess.erp.eog.sel_extrema='first_occurrence';%'avg_occurrences'
project.postprocess.erp.eog.roi_list = {  ...
          {'UP_LEOG','DOWN_LEOG'};  ... 
          {'UP_REOG','DOWN_REOG'};  ... 
          {'UP_LEOG','UP_REOG'};            ... 
          {'DOWN_LEOG','DOWN_REOG'};            ... 
};
project.postprocess.erp.eog.roi_names={'L','R','U','D'}; ...,
project.postprocess.erp.eog.numroi=length(project.postprocess.erp.eog.roi_list);


project.postprocess.erp.emg.sel_extrema='first_occurrence';%'avg_occurrences'
project.postprocess.erp.emg.roi_list = {  ...
          {'EMG1','EMG2'};  ... 
          {'EMG3','EMG4'};  ... 
          {'EMG5','EMG6'};            ... 
          {'EMG7','EMG8'};            ... 
};
project.postprocess.erp.emg.roi_names={'1','2','3','4'}; ...,
project.postprocess.erp.emg.numroi=length(project.postprocess.erp.emg.roi_list);








if isfield(project, 'postprocess')
    if isfield(project.postprocess, 'erp')
        if isfield(project.postprocess.erp, 'design')
            project.postprocess.erp = rmfield(project.postprocess.erp, 'design');
        end
    end
end


project.postprocess.erp.design(1).group_time_windows(1)     = struct('name','350-650','min',350, 'max',650);
project.postprocess.erp.design(1).group_time_windows(2)     = struct('name','750-1500','min',750, 'max',1500);
project.postprocess.erp.design(1).group_time_windows(3)     = struct('name','1700-2996','min',1700, 'max',2996);
project.postprocess.erp.design(1).group_time_windows(4)     = struct('name','750','min',0, 'max',2996);

project.postprocess.erp.design(1).subject_time_windows(1)   = struct('min',-100, 'max',100);
project.postprocess.erp.design(1).subject_time_windows(2)   = struct('min',-100, 'max',100);
project.postprocess.erp.design(1).subject_time_windows(3)   = struct('min',-100, 'max',100);
project.postprocess.erp.design(1).subject_time_windows(4)   = struct('min',-100, 'max',100);

% semi-automatic (simplified) input mode: set values for the first roi/design and
% other values will be automatically generated
% which_extrema_curve_roi = {'max';'min';'max';'max'};
% which_extrema_curve_design = cell(project.postprocess.erp.numroi,1);
% for nr =1:project.postprocess.erp.numroi
%     which_extrema_curve_design{nr} = which_extrema_curve_roi;
% end
% 
% project.postprocess.erp.design(1).which_extrema_curve = which_extrema_curve_design;



project.postprocess.erp.design(1).which_extrema_curve       = {  ... design x roi x time_windows
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


project.postprocess.erp.eog.design(1).which_extrema_curve       = {  ... design x roi x time_windows
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




project.postprocess.erp.emg.design(1).which_extrema_curve       = {  ... design x roi x time_windows
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


% parameters for onset_offset analysis

% expected deflection, if any  (to perform 1 o 2 tail t-test): 'positive' |
% 'negative' | 'unknown'


% semi-automatic (simplified) input mode: set values for the first roi/design and
% other values will be automatically generated
% deflection_polarity_list_roi = {'positive';'positive';'positive';'positive';'positive';'negative'};
% deflection_polarity_list_design = cell(project.postprocess.erp.numroi,1);
% for nr =1:project.postprocess.erp.numroi
%     deflection_polarity_list_design{nr} = deflection_polarity_list_roi;
% end
% 
% project.postprocess.erp.design(1).deflection_polarity_list = deflection_polarity_list_design;



project.postprocess.erp.design(1).deflection_polarity_list = {  ... design x roi x time_windows
                                ...   tw1      tw2  ...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 1
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 2
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... roi 3
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'negative'}  ... 
};

project.postprocess.erp.eog.design(1).deflection_polarity_list = {  ... design x roi x time_windows
                                ...   tw1      tw2  ...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 1
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 2
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... roi 3
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'negative'}  ... 
};

project.postprocess.erp.emg.design(1).deflection_polarity_list = {  ... design x roi x time_windows
                                ...   tw1      tw2  ...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 1
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 2
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... roi 3
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'negative'}  ... 
};


% minimum duration in ms of the deflections: deflections shorter than this
% threshold will be removed
project.postprocess.erp.design(1).min_duration     = 10;
project.postprocess.erp.eog.design(1).min_duration = 10;
project.postprocess.erp.emg.design(1).min_duration = 10;



for ds=2:length(project.design)
    project.postprocess.erp.design(ds) = project.postprocess.erp.design(1);
end

for ds=2:length(project.design)
    project.postprocess.erp.eog.design(ds) = project.postprocess.erp.eog.design(1);
end

for ds=2:length(project.design)
    project.postprocess.erp.emg.design(ds) = project.postprocess.erp.emg.design(1);
end


%% ===============================================================================================================================================================
% ERSP 
%===============================================================================================================================================================

project.postprocess.ersp.sel_extrema                            ='first_occurrence';%'avg_occurrences'

project.postprocess.ersp.mode.continous                         = struct('time_resolution_mode', 'continuous', 'peak_type', 'off'          , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
project.postprocess.ersp.mode.tw_group_noalign                  = struct('time_resolution_mode', 'tw'        , 'peak_type', 'group'        , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
project.postprocess.ersp.mode.tw_group_align                    = struct('time_resolution_mode', 'tw'        , 'peak_type', 'group'        , 'align', 'on',  'tw_stat_estimator', 'tw_extremum');
project.postprocess.ersp.mode.tw_individual_noalign             = struct('time_resolution_mode', 'tw'        , 'peak_type', 'individual'   , 'align', 'off', 'tw_stat_estimator', 'tw_mean');
project.postprocess.ersp.mode.tw_individual_align               = struct('time_resolution_mode', 'tw'        , 'peak_type', 'individual'   , 'align', 'on' , 'tw_stat_estimator', 'tw_extremum');


project.stats.ersp.pvalue                       = 0.05; ...0.01;        % level of significance applied in ERSP statistical analysis
project.stats.ersp.num_permutations             = 3;                    % number of permutations applied in ERP statistical analysis
project.stats.ersp.num_tails                    = 2;
project.stats.ersp.decimation_factor_times_tf   = 10;
project.stats.ersp.decimation_factor_freqs_tf   = 10;
project.stats.ersp.tf_resolution_mode           = 'continuous';         %'continuous'; 'decimate_times';'decimate_freqs';'decimate_times_freqs';'tw_fb';
project.stats.ersp.measure                      = 'dB';                 % 'Pfu';  dB decibel, Pfu, (A-R)/R * 100 = (A/R-1) * 100 = (10^.(ERSP/10)-1)*100 variazione percentuale definita da pfursheller
project.stats.eeglab.ersp.method                = 'bootstrap';          % method applied in ERP statistical analysis
project.stats.eeglab.ersp.correction            = 'none';               % multiple comparison correction applied in ERP statistical analysis
project.stats.eeglab.ersp.mask_coef             = [];                   % in the timefrequency analysis, select a time window an a frequency band of interest to do multiple comparisons, based on a priori hypotheses
project.stats.eeglab.ersp.stat_freq_bands_list  = [];
%============================================================
% FREQUENCY BANDS
%============================================================

if isfield(project, 'postprocess')
    if isfield(project.postprocess, 'ersp')
        if isfield(project.postprocess.ersp, 'frequency_bands')
            project.postprocess.ersp = rmfield(project.postprocess.ersp, 'frequency_bands');
        end
    end
end


project.postprocess.ersp.frequency_bands(1)=struct('name','teta','min',4,'max',8,'dfmin',1,'dfmax',1,'ref_roi_list',{'Cz'}, 'ref_roi_name','Cz','ref_cond', 'tscrambled', 'ref_tw_list', [0 100], 'ref_tw_name', 'gigi', 'which_realign_measure','auc');
project.postprocess.ersp.frequency_bands(2)=struct('name','mu','min',8,'max',12,'dfmin',1,'dfmax',1,'ref_roi_list',{'Cz'}, 'ref_roi_name','Cz','ref_cond', 'tscrambled', 'ref_tw_list', [0 100], 'ref_tw_name', 'gigi', 'which_realign_measure','auc');
project.postprocess.ersp.frequency_bands(3)=struct('name','beta1','min',14, 'max',20,'dfmin',1,'dfmax',1,'ref_roi_list',{'Cz'}, 'ref_roi_name','Cz','ref_cond', 'tscrambled', 'ref_tw_list', [0 100], 'ref_tw_name', 'gigi', 'which_realign_measure','auc');
project.postprocess.ersp.frequency_bands(4)=struct('name','beta2','min',20, 'max',32,'dfmin',1,'dfmax',1,'ref_roi_list',{'Cz'}, 'ref_roi_name','Cz','ref_cond', 'tscrambled', 'ref_tw_list', [0 100], 'ref_tw_name', 'gigi', 'which_realign_measure','auc');


...project.postprocess.ersp.frequency_bands(1).ref_roi = {'Fp1'};


project.postprocess.ersp.nbands = length(project.postprocess.ersp.frequency_bands);

% % semi-automatic (simplified) input mode: set values for the first roi/design and
% % other values will be automatically generated
% which_realign_measure = {'auc'};
% for nband = 1:project.postprocess.ersp.nbands
%     project.stats.ersp.narrowband.which_realign_measure = repmat(which_realign_measure,1,2); % min |max |auc for each band, select the frequency with the maximum or the minumum ersp or the largest area under the curve to reallign the narrowband
% end



project.postprocess.ersp.frequency_bands_list       = {}; ... writes something like {[4,8];[8,12];[14,20];[20,32]};
for fb=1:project.postprocess.ersp.nbands
    bands                                           = [project.postprocess.ersp.frequency_bands(fb).min, project.postprocess.ersp.frequency_bands(fb).max];
    project.postprocess.ersp.frequency_bands_list   = [project.postprocess.ersp.frequency_bands_list; {bands}];
end
project.postprocess.ersp.frequency_bands_names      = {project.postprocess.ersp.frequency_bands.name};



% %% data driven
% 
% 
% % ERP
% % data driven selection of tw-roi based on grand average
% project.postprocess.datadriven.erp.recompute_precompute                   = 'off';
% project.postprocess.datadriven.erp.precompute_folder = '';
% 
% 
% % grand average
% project.postprocess.datadriven.erp.ga.recompute                = 'on';
% project.postprocess.datadriven.erp.ga.levels_f1 = {project.design.factor1_levels};
% project.postprocess.datadriven.erp.ga.levels_f2 = {project.design.factor2_levels};
% % project.postprocess.datadriven.erp.ga.levels_f2{3} = project.postprocess.datadriven.erp.ga.levels_f2{3}(1); 
% % project.postprocess.datadriven.erp.ga.levels_f2{3} = project.postprocess.datadriven.erp.ga.levels_f2{3}(3); 
% 
% 
% % cell  array di dimensione pari al numero di disegni. ogni cella è un cell
% % array a sua volta, corrispondente a ogni interazione tra grouping factor
% % e comparing fatcor
% 
% project.postprocess.datadriven.erp.select_tw_des_stat = [0 520];
% 
% project.postprocess.datadriven.erp.ga.select_tw_des_plot = {};
% select_tw_plot = [0,2000];
% tot_des = length(project.postprocess.datadriven.erp.ga.levels_f1);
% select_tw_des_plot = {};
% for ndes = 1:tot_des
%     select_tw_s1_s2_plot = {};
% 
%     for ns1 = 1:length(project.postprocess.datadriven.erp.ga.levels_f1{ndes})
%         for ns2 = 1:length(project.postprocess.datadriven.erp.ga.levels_f2{ndes})
%             
%            select_tw_s1_s2_plot{ns1, ns2}  = select_tw_plot;
%            
%         end
%     end
%                select_tw_des_plot{ndes} = select_tw_s1_s2_plot;
% 
% end
% project.postprocess.datadriven.erp.ga.select_tw_des_plot = select_tw_des_plot;
% 
% 
% % grouping factor
% 
% project.postprocess.datadriven.erp.gf.recompute                 = 'on';
% project.postprocess.datadriven.erp.gf.levels_f1 = {project.design.factor1_levels};
% project.postprocess.datadriven.erp.gf.levels_f2 = {project.design.factor2_levels};
% 
% % cell  array di dimensione pari al numero di disegni. ogni cella è un cell
% % array a sua volta, corrispondente a ogni interazione tra grouping factor
% % e comparing fatcor
% 
% project.postprocess.datadriven.erp.gf.select_tw_des_plot = {};
% select_tw_plot = [0,2000];
% tot_des = length(project.postprocess.datadriven.erp.gf.levels_f1);
% select_tw_des_plot = {};
% for ndes = 1:tot_des
%     select_tw_s1_s2_plot = {};
% 
%     for ns1 = 1:length(project.postprocess.datadriven.erp.gf.levels_f1{ndes})
%         for ns2 = 1:length(project.postprocess.datadriven.erp.gf.levels_f2{ndes})
%             
%            select_tw_s1_s2_plot{ns1, ns2}  = select_tw_plot;
%            
%         end
%     end
%                select_tw_des_plot{ndes} = select_tw_s1_s2_plot;
% 
% end
% project.postprocess.datadriven.erp.gf.select_tw_des_plot = select_tw_des_plot;
% 
% 
% 
% 
% 
% 
% 
% 
% 
% % ERSP
% % data driven selection of tw-roi based on grand average
% project.postprocess.datadriven.ersp.recompute_precompute                   = 'off';
% project.postprocess.datadriven.ersp.precompute_folder = '';
% 
% 
% % grand average
% project.postprocess.datadriven.ersp.ga.recompute                = 'on';
% project.postprocess.datadriven.ersp.ga.levels_f1 = {project.design.factor1_levels};
% project.postprocess.datadriven.ersp.ga.levels_f2 = {project.design.factor2_levels};
% % project.postprocess.datadriven.ersp.ga.levels_f2{3} = project.postprocess.datadriven.ersp.ga.levels_f2{3}(4:end); 
% %  project.postprocess.datadriven.ersp.ga.levels_f2{3} = project.postprocess.datadriven.ersp.ga.levels_f2{3}(3); 
% 
% 
% % cell  array di dimensione pari al numero di disegni. ogni cella è un cell
% % array a sua volta, corrispondente a ogni interazione tra grouping factor
% % e comparing fatcor
% 
% project.postprocess.datadriven.ersp.select_tw_des_stat = [0 520];
% project.postprocess.datadriven.ersp.ga.select_tw_des_plot = {};
% select_tw_plot = [0,2000];
% tot_des = length(project.postprocess.datadriven.ersp.ga.levels_f1);
% select_tw_des_plot = {};
% for ndes = 1:tot_des
%     select_tw_s1_s2_plot = {};
% 
%     for ns1 = 1:length(project.postprocess.datadriven.ersp.ga.levels_f1{ndes})
%         for ns2 = 1:length(project.postprocess.datadriven.ersp.ga.levels_f2{ndes})
%             
%            select_tw_s1_s2_plot{ns1, ns2}  = select_tw_plot;
%            
%         end
%     end
%                select_tw_des_plot{ndes} = select_tw_s1_s2_plot;
% 
% end
% project.postprocess.datadriven.ersp.ga.select_tw_des_plot = select_tw_des_plot;
% 
% 
% % grouping factor
% 
% project.postprocess.datadriven.ersp.gf.recompute                 = 'on';
% project.postprocess.datadriven.ersp.gf.levels_f1 = {project.design.factor1_levels};
% project.postprocess.datadriven.ersp.gf.levels_f2 = {project.design.factor2_levels};
% 
% % cell  array di dimensione pari al numero di disegni. ogni cella è un cell
% % array a sua volta, corrispondente a ogni interazione tra grouping factor
% % e comparing fatcor
% 
% project.postprocess.datadriven.ersp.gf.select_tw_des_plot = {};
% select_tw_plot = [0,2000];
% tot_des = length(project.postprocess.datadriven.ersp.gf.levels_f1);
% select_tw_des_plot = {};
% for ndes = 1:tot_des
%     select_tw_s1_s2_plot = {};
% 
%     for ns1 = 1:length(project.postprocess.datadriven.ersp.gf.levels_f1{ndes})
%         for ns2 = 1:length(project.postprocess.datadriven.ersp.gf.levels_f2{ndes})
%             
%            select_tw_s1_s2_plot{ns1, ns2}  = select_tw_plot;
%            
%         end
%     end
%                select_tw_des_plot{ndes} = select_tw_s1_s2_plot;
% 
% end
% project.postprocess.datadriven.ersp.gf.select_tw_des_plot = select_tw_des_plot;
%==============================================================
% NARROW BAND
%==============================================================
project.stats.ersp.do_narrowband                    = 'off';                % off|ref|auto  the adjustment of spectral band for each subject: off=no adhiustment, ref adjust based on a ref condition, auto ajust each condition separately
project.stats.ersp.narrowband.group_tmin            = [];                   % lowest time of the time windows considered to select the narrow band. if empty, consider the start of the epoch
project.stats.ersp.narrowband.group_tmax            = [];                   % highest time of the time windows considered to select the narrow band. if empty, consider the end of the epoch
project.stats.ersp.narrowband.dfmin                 = 2;                    % low variation in Hz from the barycenter frequency
project.stats.ersp.narrowband.dfmax                 = 2;                    % high variation in Hz from the barycenter frequency

project.stats.ersp.narrowband.which_realign_measure = {'max','min','min','min'}; % min |max |auc for each band, select the frequency with the maximum or the minumum ersp or the largest area under the curve to reallign the narrowband
project.stats.ersp.narrowband.which_realign_param   = {'cog_pos','cog_neg','cog_neg','cog_neg'};             % fnb | cog_pos | cog_neg | cog_all : set if re-allign the narrowband to the peak (defined above) of to the center-of-gravity within the wide band


% **********CHECK*****************
if length(project.stats.ersp.narrowband.which_realign_measure) ~= project.postprocess.ersp.nbands
    error(['number of which_realign_measure ' num2str(lenght(project.stats.ersp.narrowband.which_realign_measure)) ' is different than number of defined bands (' num2str(project.postprocess.ersp.nbands) ')']);
end
if length(project.stats.ersp.narrowband.which_realign_param) ~= project.postprocess.ersp.nbands
    error(['number of which_realign_param ' num2str(lenght(project.stats.ersp.narrowband.which_realign_param)) ' is different than number of defined bands (' num2str(project.postprocess.ersp.nbands) ')']);
end

if strcmp(project.stats.ersp.do_narrowband, 'ref')
    for fb=1:project.postprocess.ersp.nbands
        if isempty(project.postprocess.ersp.frequency_bands(fb).ref_roi_list)
           error('you asked to calcultate the narrow band with the ref parameters, but you did not insert the ref_roi_list'); 
        end
    end
end
%==============================================================
% ROI LIST
%==============================================================

project.postprocess.ersp.roi_list = { ...
            {'F5','F7','AF7','FT7'};  ... left IFG
          {'F6','F8','AF8','FT8'};  ... right IFG
          {'FC3','FC5'};            ... l PMD
          {'FC4','FC6'};            ... r PMD    
          {'C3'};                   ... iM1 hand
          {'C4'};                   ... cM1 hand
          {'Cz'}   
};
project.postprocess.ersp.roi_names                              = {'contralateral-SM1','ipsilateral-SM1','SMA','ipsilateral-PMd','contralateral-PMd','ipsilateral-ifg','contralateral-ifg'}; ... ,'left-ipl','right-ipl','left-spl','right-spl','left-sts','right-sts','left-occipital','right-occipital'};
project.postprocess.ersp.numroi                                 = length(project.postprocess.ersp.roi_list);



project.postprocess.ersp.eog.roi_list = { ...
          {'UP_LEOG','DOWN_LEOG'};  ... 
          {'UP_REOG','DOWN_REOG'};  ... 
          {'UP_LEOG','UP_REOG'};            ... 
          {'DOWN_LEOG','DOWN_REOG'};     
};
project.postprocess.ersp.eog.roi_names                              = {'L','R','U','D'}; ... 
project.postprocess.ersp.eog.numroi                                 = length(project.postprocess.ersp.eog.roi_list);


project.postprocess.ersp.emg.roi_list = {  ...
          {'EMG1','EMG2'};  ... 
          {'EMG3','EMG4'};  ... 
          {'EMG5','EMG6'};            ... 
          {'EMG7','EMG8'};            ... 
};
project.postprocess.ersp.emg.roi_names={'1','2','3','4'}; ...,
project.postprocess.ersp.emg.numroi=length(project.postprocess.ersp.emg.roi_list);



if isfield(project, 'postprocess')
    if isfield(project.postprocess, 'ersp')
        if isfield(project.postprocess.ersp, 'design')
            project.postprocess.ersp = rmfield(project.postprocess.ersp, 'design');
        end
    end
end

project.postprocess.ersp.nroi = length(project.postprocess.ersp.roi_list);
project.postprocess.ersp.eog.nroi = length(project.postprocess.ersp.eog.roi_list);
project.postprocess.ersp.emg.nroi = length(project.postprocess.ersp.emg.roi_list);
%==============================================
% DESIGNS TIME WINDOWS
%==============================================

project.postprocess.ersp.design(1).group_time_windows(1)        = struct('name','350-650','min',350, 'max',650);
project.postprocess.ersp.design(1).group_time_windows(2)        = struct('name','750-1500','min',750, 'max',1500);
project.postprocess.ersp.design(1).group_time_windows(3)        = struct('name','1700-2500','min',1700, 'max',2500);
project.postprocess.ersp.design(1).group_time_windows(4)        = struct('name','350-2500','min',350, 'max',2500);
    
% ref_roi is used by the function [extr_lat] = proj_get_erp_peak_info(project, out_file)
project.postprocess.erp.design(1).group_time_windows(1).ref_roi = [project.postprocess.erp.roi_list(1), project.postprocess.erp.roi_list(2)];

project.postprocess.ersp.design(1).subject_time_windows(1)      = struct('min',-100, 'max',100);
project.postprocess.ersp.design(1).subject_time_windows(2)      = struct('min',-100, 'max',100);
project.postprocess.ersp.design(1).subject_time_windows(3)      = struct('min',-100, 'max',100);
project.postprocess.ersp.design(1).subject_time_windows(4)      = struct('min',-100, 'max',100);


% semi-automatic (simplified) input mode: set values for the first roi/design and
% other values will be automatically generated
%  which_extrema_curve_roi = {{'max'};{'min'};{'min'};{'min'}};
%     which_extrema_curve_design = cell(project.postprocess.ersp.numroi,1);
%     for nr =1:project.postprocess.ersp.nroi
%         which_extrema_curve_design{nr} = which_extrema_curve_roi;
%     end
%     project.postprocess.ersp.design(1).which_extrema_curve_continuous = which_extrema_curve_design;

% extreme to be searched in the continuous curve ( NON time-window mode)
project.postprocess.ersp.design(1).which_extrema_curve_continuous = {     .... design x roi x freq band
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

% % ****CHECK****
% if size(project.postprocess.ersp.design(1).which_extrema_curve_continuous, 1) ~= project.postprocess.ersp.nroi
%    error(['number of roi in which_extrema_curve_continuous parameters (' num2str(size(project.postprocess.ersp.design(1).which_extrema_curve_continuous,1)) ') does not correspond to number of defined ROI (' num2str(project.postprocess.ersp.nroi) ')']); 
% else
%     if size(project.postprocess.ersp.design(1).which_extrema_curve_continuous{1}, 1) ~= project.postprocess.ersp.nbands
%         error(['number of bands in the first roi of which_extrema_curve_continuous parameters (' num2str(size(project.postprocess.ersp.design(1).which_extrema_curve_continuous{1},1)) ') does not correspond to number of defined frequency bands (' num2str(project.postprocess.ersp.nbands) ')']); 
%     end
% end
%*************

% semi-automatic (simplified) input mode: set values for the first roi/design and
% other values will be automatically generated
% group_time_windows_continuous_roi = {{};{};{};{}};
%     group_time_windows_continuous_design = cell(project.postprocess.ersp.numroi,1);
%     for nr =1:project.postprocess.ersp.numroi
%         group_time_windows_continuous_design{nr} = group_time_windows_continuous_roi;
%     end
%     project.postprocess.ersp.design(1).which_extrema_curve_continuous = group_time_windows_continuous_design;


% time interval for searching extreme in the continuous curve ( NON time-window mode)
project.postprocess.ersp.design(1).group_time_windows_continuous = {     .... design x roi x freq band
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

% ****CHECK****
if size(project.postprocess.ersp.design(1).group_time_windows_continuous, 1) ~= project.postprocess.ersp.nroi
   error(['number of roi in group_time_windows_continuous parameters (' num2str(size(project.postprocess.ersp.design(1).group_time_windows_continuous,1)) ') does not correspond to number of defined ROI (' num2str(project.postprocess.ersp.nroi) ')']); 
else
    if size(project.postprocess.ersp.design(1).group_time_windows_continuous{1}, 1) ~= project.postprocess.ersp.nbands
        error(['number of bands in the first roi of group_time_windows_continuous parameters (' num2str(size(project.postprocess.ersp.design(1).group_time_windows_continuous{1},1)) ') does not correspond to number of defined frequency bands (' num2str(project.postprocess.ersp.nbands) ')']); 
    end
end
%*************



% semi-automatic (simplified) input mode: set values for the first roi/design and
% other values will be automatically generated
% group_which_extrema_curve_tw_roi =  {... roi 1
%         %                                     ...  tw1    tw2   tw3   tw4   tw5
%         {'max';'max';'max';'max';'max'}; ... frequency band 1
%         {'min';'min';'min';'min';'min'}; ... frequency band 2
%         {'min';'min';'min';'min';'min'}; ... frequency band 3
%         {'min';'min';'min';'min';'min'}  ... frequency band 4
%         };
%     group_which_extrema_curve_tw_design = cell(project.postprocess.ersp.numroi,1);
%     for nr =1:project.postprocess.ersp.numroi
%         group_which_extrema_curve_tw_design{nr} = group_which_extrema_curve_tw_roi;
%     end
%     project.postprocess.ersp.design(1).which_extrema_curve_tw = group_which_extrema_curve_tw_design;
%     



% extreme to be searched in each time window (time-window mode)
project.postprocess.ersp.design(1).which_extrema_curve_tw = {     .... design x roi x freq band x time window
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
                                    {... roi 3
                                        {'max';'max';'max';'max';'max'}; ... frequency band 1
                                        {'min';'min';'min';'min';'min'}; ... frequency band 2
                                        {'min';'min';'min';'min';'min'}; ... frequency band 3
                                        {'min';'min';'min';'min';'min'}  ... frequency band 4
                                    };                                    
};




project.postprocess.ersp.eog.design(1).which_extrema_curve       = {  ... design x roi x time_windows
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
                                    {... roi 3
                                        {'max';'max';'max';'max';'max'}; ... frequency band 1
                                        {'min';'min';'min';'min';'min'}; ... frequency band 2
                                        {'min';'min';'min';'min';'min'}; ... frequency band 3
                                        {'min';'min';'min';'min';'min'}  ... frequency band 4
                                    };                                    
};



 project.postprocess.ersp.design(1).deflection_polarity_list = {  ... design x roi x frequency band x time_windows
                               {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
                                 {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
                                {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
                                {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
                                {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
                                {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
                                {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
                                {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
                                {...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... frequency band
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                               };...
};



project.postprocess.ersp.eog.design(1).deflection_polarity_list = {  ... design x roi x time_windows
                                ...   tw1      tw2  ...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 1
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 2
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... roi 3
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'negative'}  ... 
};


project.postprocess.ersp.emg.design(1).deflection_polarity_list = {  ... design x roi x time_windows
                                ...   tw1      tw2  ...
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 1
                                {'positive';'positive';'positive';'positive';'positive';'negative'}; ... roi 2
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... roi 3
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'positive'}; ... 
                                {'positive';'positive';'positive';'positive';'positive';'negative'}  ... 
};

project.postprocess.ersp.design(1).min_duration = 10;
project.postprocess.ersp.eog.design(1).min_duration = 10;
project.postprocess.ersp.emg.design(1).min_duration = 10;




for ds=2:length(project.design)
    project.postprocess.ersp.design(ds) = project.postprocess.ersp.design(1);
end

for ds=2:length(project.design)
    project.postprocess.ersp.eog.design(ds) = project.postprocess.ersp.eog.design(1);
end


for ds=2:length(project.design)
    project.postprocess.ersp.emg.design(ds) = project.postprocess.ersp.emg.design(1);
end


% semi-automatic (simplified) input mode: set values for the first roi/design and
% other values will be automatically generated
%  design_factors_ordered_level = {{} {}};
%     project.postprocess.design_factors_ordered_levels = cell(length(project.design),1);
%     for ds=1:length(project.design)
%         project.postprocess.design_factors_ordered_levels{ds} = design_factors_ordered_level;
%     end
%     

%cla aggiungo questo per riordinare eventualmente in post-processing i
%livelli di qualche fattore

project.postprocess.design_factors_ordered_levels={...
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

%% sleep EEG analysis

project.sleep.sleep_stages.markers = {'W','N1','N2','N3','N4','REM'};
project.sleep.sleep_stages.colors = {[1 0 0],[0 1 0],[0 0 1],[0 1 1],[1 0 1],[1 1 0]};
project.sleep.channels_colors = 'off'; % 'on'|'off' when on plot channels with different colors 
project.sleep.reset_marks = 0; % reset or initialize the marks structure 

project.sleep.sleep_stages.markers = {'W','N1','N2','N3','N4','REM'};
project.sleep.sleep_stages.colors = {[1 0 0],[0 1 0],[0 0 1],[0 1 1],[1 0 1],[1 1 0]};
project.sleep.channels_colors = 'off'; % 'on'|'off' when on plot channels with different colors 
project.sleep.reset_marks = 0; % reset or initialize the marks structure 

project.sleep.marks(1).label = 's';%spindle
project.sleep.marks(1).color = [1 0.5 0.5];
project.sleep.marks(1).description = 'spindle';


project.sleep.marks(2).label = 'k';%k-complex
project.sleep.marks(2).color = [0.5 1 0.5];
project.sleep.marks(2).description = 'k-complex';

% set the vised commands for insert sleep marks and stages, see
% https://bucanl.github.io/SDC-VISED-MARKS/02-options/index.html
 
project.sleep.vised.marks_y_loc = 0.15; % y of the makers in the scoring figure

project.sleep.vised.keyselectcommand=...
    {...
    't,ve_eegplot(''topoplot'',gcbf)';...
    'r,ve_eegplot(''drawp'',0)';...
    'm,ve_edit(''awm'',''manual'')';...
    'M,ve_edit(''rwm'',''manual'')';...
    's,ve_edit(''awm'',''s'')';... insert SPINDLE
    'S,ve_edit(''rwm'',''s'')';... remove spindle
    'k,ve_edit(''awm'',''k'')';... insert K-COMPLEX
    'K,ve_edit(''rwm'',''k'')';... remove k complex
    'a,ve_edit(''apm'',''W'')';...
    'A,ve_edit(''rwm'',''W'')';...
    'b,ve_edit(''apm'',''N1'')';... insert all page stage n1
    'B,ve_edit(''rwm'',''N1'')';... remove selected area n1 (select by drag cursor)
    'c,ve_edit(''apm'',''N2'')';...
    'C,ve_edit(''rwm'',''N2'')';...
    'd,ve_edit(''apm'',''N3'')';...
    'D,ve_edit(''rwm'',''N3'')';...
    'e,ve_edit(''apm'',''N4'')';...
    'E,ve_edit(''rwm'',''N4'')';...
    'f,ve_edit(''apm'',''REM'')';...
    'F,ve_edit(''rwm'',''REM'')';...   
    };...


%% HUME SLEEP SCORING
 % cc commentare
project.sleep.hume.stageData.stageNames = {'W'; 'N1'; 'N2'; 'N3'; 'N4'; 'REM'; 'MT'}; % DO NOT EDIT: sleep stage coding for HUME
project.sleep.hume.stageData.stageNames_spindles = {'N2'; 'N3'; 'N4'}; % DO NOT EDIT: sleep stage coding for HUME

project.sleep.hume.reset_stageData = 1; % reset sleep staging data
% creo campi custom per gestire parametri
project.sleep.hume.stageData.Flims_global = [.05 20];%[.05 20];
project.sleep.hume.stageData.Flims_delta = [.5 4];%[.5 4.75];
project.sleep.hume.stageData.Flims_sigma = [10 14];%[.05 20];
project.sleep.hume.stageData.project = project;
project.sleep.hume.stageData.spect_win = 2;% window length for spectrogram calculation, default 5 secs


% 

%% ===============================================
% BRAINSTORM 
%% ===============================================
project.stats.brainstorm.pvalue                 = 0.025; ...0.01;       % level of significance applied in ERSP statistical analysis
project.stats.brainstorm.correction             = 'fdr';                % multiple comparison correction applied in ERP statistical analysis


%% ===============================================
% SPM
%% ===============================================
project.stats.spm.pvalue                        = 0.025; ...0.01;       % level of significance applied in ERSP statistical analysis
project.stats.spm.correction                    = 'fwe';                % multiple comparison correction applied in ERP statistical analysis

% for each design of interest, perform or not statistical analysis of erp
project.stats.show_statistics_list              = {'on','on','on','on','on','on','on','on'}; 

%% ======================================================================================================
% O:    RESULTS DISPLAY
% ======================================================================================================

% CURVES

% ERP
project.results_display.erp.time_smoothing                      = 10;           % frequency (Hz) of low-pass filter to be applied (only for visualization) of ERP data
project.results_display.erp.time_range.s                        = [project.study.erp.tmin_analysis.s project.study.erp.tmax_analysis.s];       % time range for erp representation

% ERP CURVE

project.results_display.filter_freq                             = 10;           %frequency (Hz) of low-pass filter to be applied (only for visualization) of ERP data

project.results_display.ylim_plot                               = [];           %y limits (uV)for the representation of ERP
project.results_display.erp.single_subjects                     = 'off';        % display patterns of the single subjcts (keeping the average pattern)
project.results_display.erp.masked_times_max                    = [];           % number of ms....all the timepoints before this values are not considered for statistics
project.results_display.erp.do_plots                            = 'on';        %
project.results_display.erp.show_text                           = 'on';         %

project.results_display.erp.compact_plots                       = 'on';         % display (curve) plots with different conditions/groups on the same plots
project.results_display.erp.compact_h0                          = 'on';         % display parameters for compact plots
project.results_display.erp.compact_v0                          = 'on';         %
project.results_display.erp.compact_sem                         = 'off';        %
project.results_display.erp.compact_stats                       = 'on';         %
project.results_display.erp.compact_display_xlim                = [];           %
project.results_display.erp.compact_display_ylim                = [];           %
project.results_display.erp.display_only_significant_curve      = 'on';         % on

% ERP TOPO
project.results_display.erp.compact_plots_topo                  = 'on';        %
project.results_display.erp.set_caxis_topo_tw                   = [];           %
project.results_display.erp.display_only_significant_topo       = 'on';         % on
project.results_display.erp.display_only_significant_topo_mode  = 'surface';    % 'electrodes';
project.results_display.erp.display_compact_topo_mode           = 'errorbar';    % 'boxplot'; ... 'errorbar'
project.results_display.erp.display_compact_show_head           = 'off';        % 'on'|'off'
project.results_display.erp.z_transform                        = 'on';         % 'on'|'off' z-transform data data for each roi, and tw to allow to plot all figures on the same scale



% ERP HEADPLOT
project.results_display.erp.headplot.view_list                 = [0,  60; ...
                                                                  0, -60  ...
                                                                  ];

%  'view'       - Camera viewpoint in deg. [azimuth elevation]
%                    'back'|'b'=[  0 30]; 'front'|'f'=[180 30]
%                    'left'|'l'=[-90 30]; 'right'|'r'=[ 90 30];
%                    'frontleft'|'bl','backright'|'br', etc.,
%                    'top'=[0 90],  Can rotate with mouse {default [143 18]}



% ERP CC
project.results_display.cclim_plot                               = [];           %y limits for the representation of cross correlation
project.results_display.xlim_plot                                = [];           % time (lag) limits in ms for the representation of cross correlation


% ERSP
project.results_display.ersp.time_range.s                       = [project.study.ersp.tmin_analysis.s project.study.ersp.tmax_analysis.s];     % time range for erp representation
project.results_display.ersp.frequency_range                    = [project.study.ersp.fmin_analysis project.study.ersp.fmax_analysis];         % frequency range for ersp representation
project.results_display.ersp.do_plots                           = 'on';        %
project.results_display.ersp.show_text                          = 'on';         %
project.results_display.ersp.z_transform                        = 'on';         % 'on'|'off' z-transform data data for each roi, band and tw to allow to plot all figures on the same scale
project.results_display.ersp.which_error_measure                = 'sem';        % 'sd'|'sem'; which error measure is adopted in the errorbar: standard deviation or standard error
project.results_display.ersp.freq_scale                         = 'linear';     % 'log'|'linear' set frequency scale in time-frequency plots
project.results_display.ersp.masked_times_max                   = [];
project.results_display.ersp.display_pmode                      = 'raw_diff';   % 'raw_diff' | 'abs_diff'| 'standard'; plot p values in a time-frequency space. 'raw_diff': for 2 levels factors, show p values multipled with the raw difference between the average of level 1 and the average of level 2; 'abs_diff': for 2 levels factors, show p values multipled with the difference betwenn the abs of the average of level 1 and the abs of the average of level 2 (more focused on the strength of the spectral variatio with respect to the sign of the variation); 'standard': the standard mode of EEGLab, only indicating a significant difference between levels, without providing information about the sign of the difference, it's the only representation avalillable for factors with >2 levels (for which a difference cannot be simply calculated). 

% ERSP CURVE
project.results_display.ersp.compact_plots                      = 'on';         % display (curve) plots with different conditions/groups on the same plots
project.results_display.ersp.single_subjects                    = 'off';        % display patterns of the single subjcts (keeping the average pattern)
project.results_display.ersp.compact_h0                         = 'on';         % 'on'|'off'show x=0 axis
project.results_display.ersp.compact_v0                         = 'on';         % 'on'|'off' show y=0 axis
project.results_display.ersp.compact_sem                        = 'off';        % 'on'|'off' show standard error in compact plots (for compact topographic the error is always showed)
project.results_display.ersp.compact_stats                      = 'on';         % 'on'|'off' indicate significant differences in the compact plots, using a black orizontal bar for continuous curve plots and stars for time-windows plots 
project.results_display.ersp.compact_display_xlim               = [];           % [x_min x_max] set the x limits in ms for compact plots
project.results_display.ersp.compact_display_ylim               = [];           % [y_min y_max] set the y limits for compact plots 
project.results_display.ersp.stat_time_windows_list             = [];           % time windows in milliseconds [tw1_start,tw1_end; tw2_start,tw2_end] considered for statistics
project.results_display.ersp.set_caxis_tf                       = [];           % [color_min color_max] set the color limits of the time-frequency plots 
project.results_display.ersp.display_only_significant_curve     = 'on';         % on % the threshold is always set, however you can choose to display only the significant p values or all the p values (in the curve plots the threshold is added as a landmark)

% ERSP TF
project.results_display.ersp.display_only_significant_tf        = 'on';         % 'on'|'off'display only significant values or all values
project.results_display.ersp.display_only_significant_tf_mode   ='binary';      % 'thresholded'|'binary'; plot comparison between time frequency distributions; thrsholded: show for each condition only ERSP correspoding to significant differences, binary: show classical EEGLAB representation 

% ERSP TOPO
project.results_display.ersp.compact_plots_topo                 = 'on';         % 'on'|'off' for each time window, plot compact topographic plot with bot topographic location of the roi and multiple comparisons between conditions OR standard EEGLAB topographic distribution plots (consider the wolwe scalp)
project.results_display.ersp.set_caxis_topo_tw_fb               = [];           % [color_min color_max] set the color limits of the topographic plots
project.results_display.ersp.display_only_significant_topo      = 'on';         % on|off display only significant values or all values
project.results_display.ersp.display_only_significant_topo_mode = 'surface';    % 'surface'|'electrodes' change the way to show significant differences: show an interpolated surface between electrodes with significant differences or classical representation, i.e. significant electrodes in red
project.results_display.ersp.display_compact_topo_mode          = 'errorbar';    % 'boxplot'|'errorbar' display boxplot with single subjects represented by red points (complete information about distribution) or error bar (syntetic standard representation)
project.results_display.ersp.display_compact_show_head          = 'off';        %'on'|'off' show the topographical representation of the roi (the head with the channels of the roi in red and te others in black)


%% ======================================================================================================
% P:    EXPORT
% ======================================================================================================
export.r.bands=[];
for nband=1:length(project.postprocess.ersp.frequency_bands_names)
    export.r.bands(nband).freq          = project.postprocess.ersp.frequency_bands_list{nband};
    export.r.bands(nband).name          = project.postprocess.ersp.frequency_bands_names{nband};
end

%% ======================================================================================================
% Q:    CLUSTERING
% ======================================================================================================
project.clustering.channels_file_name           = 'cluster_projection_channel_locations.loc';
project.clustering.channels_file_path           = ''; ... later set by define_paths















%% ======================================================================================================
% R:    BRAINSTORM
% ======================================================================================================
project.brainstorm.db_name='musicians_active';                  ... must correspond to brainstorm db name

project.brainstorm.paths.db                             = '';
project.brainstorm.paths.data                           = '';
project.brainstorm.paths.channels_file                  = '';


%% STUDY
project.brainstorm.study.use_same_montage                     = 1;
project.brainstorm.study.default_anatomy                      = 'Colin27';
project.brainstorm.study.channels_file_name                   = 'brainstorm_channel_biosemi_65.mat';
project.brainstorm.study.channels_file_type                   = 'BST';
project.brainstorm.study.channels_file_path                   = ''; ... later set by define_paths
    



%% SENSORS

project.brainstorm.sensors.name_maineffects    = {'M' 'MM' '300' '100'};
project.brainstorm.sensors.tot_num_contrasts   = project.epoching.numcond + length(project.brainstorm.sensors.name_maineffects);

% used for ERP differences and paired ttest
project.brainstorm.sensors.pairwise_comparisons = { ...
                                                    {'M-100', 'MM-100'}; ...
                                                    {'M-300', 'MM-300'}; ...
                                                   };

                                               




                            


%% SOURCES

% average FILE used to calculate sources
% project.brainstorm.average_file_name    = 'data_average_tw_average_5_samples';        % after temporal reduction 1 sample for each component (in case of one component, it adds a fake second TP)
% project.brainstorm.average_file_name    = 'data_average_tw_average_all_samples';      % after temporal reduction (2*window_samples_halfwidth + 1) * ncomponents 
project.brainstorm.average_file_name    = 'data_average';  

project.brainstorm.sources.flatting_method = 1; % 0: no flatting, 1: norm, 2: PCA

project.brainstorm.conductorvolume.surf_bem_file_name   = 'headmodel_surf_openmeeg.mat';
project.brainstorm.conductorvolume.vol_bem_file_name    = 'headmodel_vol_openmeeg.mat';

project.brainstorm.sources.params =  {
%                           {'norm', 'dspm',    'orient',   'free',  'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
%                           {'norm', 'dspm',    'orient',   'fixed', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
                            {'norm', 'wmne',    'orient',   'free',  'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
                            {'norm', 'wmne',    'orient',   'fixed', 'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', 0                                         , 'loose_value', 0}; ...
%                           {'norm', 'sloreta', 'orient',   'free',  'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
%                           {'norm', 'dspm',    'orient',   'free',  'headmodelfile', project.brainstorm.conductorvolume.surf_bem_file_name,  'tag', 'surf', 'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
%                           {'norm', 'mne',     'orient',   'free',  'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name,   'tag', 'vol',  'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
%                           {'norm', 'mne',     'orient',   'fixed', 'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name,   'tag', 'vol',  'project.operations.do_norm', 0                                         , 'loose_value', 0}; ...
%                           {'norm', 'sloreta', 'orient',   'free',  'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name,   'tag', 'vol',  'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
%                           {'norm', 'dspm',    'orient',   'free',  'headmodelfile', project.brainstorm.conductorvolume.vol_bem_file_name,   'tag', 'vol',  'project.operations.do_norm', project.brainstorm.sources.flatting_method, 'loose_value', 0}; ...
                        };

                    
                    
                    
%%
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% SOURCES DIMENSIONALITY REDUCTION & EXPORT
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------

% TEMPORAL

% ------- time reduction (file containing the components' peaks...it's an ERP CURVE TW with individual peak calculation) 
% ONLY suited for that design (usually the #1) reporting all the plain conditions. not structured factors
project.brainstorm.postprocess.tw_latencies_file        = '/data/projects/PAP/moving_scrambled_walker/results/OCICA_250_raw/erp_N2_central_reduced_100000perm_wnd20ms_380-480_eye_regr_sign_all_full_005_fdr/all-erp_curve_individual_align-16-Dec-2015-17-39-21/erp_curve_roi-stat.mat';

project.brainstorm.postprocess.group_time_windows(1)    = struct('name', '211', 'min', 211.3, 'max', 211.3);

% project.brainstorm.postprocess.analysis_times                       = {{'t-4', '-0.4000, -0.3040', 'mean'; 't-3', '-0.3000, -0.2040', 'mean'; 't-2', '-0.2000, -0.1040', 'mean'; 't-1', '-0.1000, -0.0040', 'mean'; 't1', '0.0000, 0.0960', 'mean'; 't2', '0.1000, 0.1960', 'mean'; 't3', '0.2000, 0.2960', 'mean'; 't4', '0.3000, 0.3960', 'mean'; 't5', '0.4000, 0.4960', 'mean'; 't6', '0.5000, 0.5960', 'mean'; 't7', '0.6000, 0.6960', 'mean'; 't8', '0.7000, 0.7960', 'mean'; 't9', '0.8000, 0.8960', 'mean'; 't10', '0.9000, 0.9960', 'mean'}};




project.brainstorm.postprocess.time_reduction_tag_list                = {'sloreta | free | surf',...
    };


project.brainstorm.postprocess.sources_tag_list            = {'sloreta | free | surf',...
    'sloreta | free | surf | tw_average_C1',...
    'sloreta | free | surf | tw_average_P140', ...
    'sloreta | free | surf | tw_average_ACOP'  };






% 
%                     time_reduction_tag_list                = {'sloreta | free | surf',...
%                                             };
%                                        
% 
% postprocess_sources_tag_list            = {'sloreta | free | surf',...
%                                            'sloreta | free | surf | tw_average_C1',...
%                                            'sloreta | free | surf | tw_average_P140', ...
%                                            'sloreta | free | surf | tw_average_ACOP'  };
% 





% Assuming you have N components. When you perform time reduction, it creates two ERP file:
% 1)    one ERP average file with N timepoints calculated as the average of the
%       window_samples_halfwidth samples before and after the obtained peak + the peak s tp (thus you get 2*window_samples_halfwidth + 1 samples)
% 2)    one ERP average file with N*(2*window_samples_halfwidth + 1) timepoints
project.brainstorm.postprocess.window_samples_halfwidth     = 2;        % number of TP before and after the calculated peak


% SPATIAL
project.brainstorm.postprocess.downsample.standard_atlas(1).atlasname = 'Desikan-Killiany';
project.brainstorm.postprocess.downsample.standard_atlas(1).scouts_names = {...
    'bankssts L', 'bankssts R', ...
    'caudalanteriorcingulate L', 'caudalanteriorcingulate R', 'caudalmiddlefrontal L', 'caudalmiddlefrontal R',...
    'cuneus L', 'cuneus R', 'entorhinal L', 'entorhinal R',...
    'frontalpole L', 'frontalpole R', 'fusiform L', 'fusiform R',...
    'inferiorparietal L', 'inferiorparietal R', 'inferiortemporal L', ...
    'inferiortemporal R', 'insula L', 'insula R', ...
    'isthmuscingulate L', 'isthmuscingulate R', 'lateraloccipital L', 'lateraloccipital R',...
    'lateralorbitofrontal L', 'lateralorbitofrontal R', 'lingual L', 'lingual R',...
    'medialorbitofrontal L', 'medialorbitofrontal R', 'middletemporal L', 'middletemporal R', ...
    'paracentral L', 'paracentral R', 'parahippocampal L', 'parahippocampal R',...
    'parsopercularis L', 'parsopercularis R', 'parsorbitalis L', 'parsorbitalis R', 'parstriangularis L',...
    'parstriangularis R', 'pericalcarine L', 'pericalcarine R', ...
    'postcentral L', 'postcentral R', 'posteriorcingulate L', 'posteriorcingulate R', ...
    'precentral L', 'precentral R', 'precuneus L', 'precuneus R',...
    'rostralanteriorcingulate L', 'rostralanteriorcingulate R', ...
    'rostralmiddlefrontal L', 'rostralmiddlefrontal R', ...
    'superiorfrontal L', 'superiorfrontal R', 'superiorparietal L', 'superiorparietal R', ...
    'superiortemporal L', 'superiortemporal R', 'supramarginal L', 'supramarginal R', ...
    'temporalpole L', 'temporalpole R', 'transversetemporal L', 'transversetemporal R'};

project.brainstorm.postprocess.downsample.standard_atlas(2).atlasname = 'Brodmann-thresh';
project.brainstorm.postprocess.downsample.standard_atlas(2).scouts_names =...
{...
    'BA1 L', 'BA1 R', 'BA2 L', 'BA2 R', ...
    'BA3a L', 'BA3a R', 'BA3b L', 'BA3b R', ...
    'BA44 L', 'BA44 R', 'BA45 L', 'BA45 R', ...
    'BA4a L', 'BA4a R', 'BA4p L', 'BA4p R',...
    'BA6 L', 'BA6 R',...
    'MT L', 'MT R',...
    'V1 L', 'V1 R', 'V2 L', 'V2 R'...
};

project.brainstorm.postprocess.downsample_atlasname         = ...
    project.brainstorm.postprocess.downsample.standard_atlas(1).atlasname;...'s3000';  % name of the atlas defined in BST GUI
project.brainstorm.postprocess.scouts_names             = ...
    project.brainstorm.postprocess.downsample.standard_atlas(1).scouts_names;...{'r_ACC','r_MCC','r_IFG'};
project.brainstorm.postprocess.numscouts                = length(project.brainstorm.postprocess.scouts_names);
project.brainstorm.postprocess.scoutfunc_str            = 'mean'; % 'mean'|'max'|'pca'|'std'|'all'

% SPECTRAL
project.brainstorm.postprocess.analysis_bands={{ ...
                    project.postprocess.ersp.frequency_bands(1).name, [num2str(project.postprocess.ersp.frequency_bands(1).min) ', ' num2str(project.postprocess.ersp.frequency_bands(1).max)], 'mean'; ...
                    project.postprocess.ersp.frequency_bands(2).name, [num2str(project.postprocess.ersp.frequency_bands(2).min) ', ' num2str(project.postprocess.ersp.frequency_bands(2).max)], 'mean'; ...
                    project.postprocess.ersp.frequency_bands(3).name, [num2str(project.postprocess.ersp.frequency_bands(3).min) ', ' num2str(project.postprocess.ersp.frequency_bands(3).max)], 'mean'; ...
%                     project.postprocess.ersp.frequency_bands(4).name, [num2str(project.postprocess.ersp.frequency_bands(4).min) ', ' num2str(project.postprocess.ersp.frequency_bands(4).max)], 'mean' ...
                                  }};
 
                              
%% TIME FREQUENCY ANALYSIS

% Morlet wavelet

project.brainstorm.tf.scout_tag_list                = {'sloreta | free | surf',...
                                        };
project.brainstorm.tf.Freqs = project.study.ersp.freqout_analysis_interval;
project.brainstorm.tf.MorletFc = 1;% central frequency of Morlet wavelet function (Hz)
project.brainstorm.tf.MorletFwhmTc = 3; % time resolution (FWHM) (sec)
project.brainstorm.tf.RemoveEvoked = 1;
project.brainstorm.tf.normalize = 'none'; % 'none' | 'multiply':1/f compensation: Multiply output values by frequency
project.brainstorm.tf.measure = 'power';% %'magnitude' | 'power'
project.brainstorm.tf.output  = 'average'; % 'average' recommended | 'all' save alla files, requires uge amount of space 
project.brainstorm.tf.ClusterFuncTime = 'after'; % 'after' | 'before' compute tf with respect to cluter sources


% baseline correction
project.brainstorm.tf.bc.baseline = [project.epoching.bc_st.s, project.epoching.bc_end.s];
project.brainstorm.tf.bc.method = 'db'; 
% possible baseline corrections
% 'zscore', ...  % Z-score transformation:    x_std = (x - &mu;) / &sigma;
% 'ersd', ...  % Event-related perturbation (ERS/ERD):    x_std = (x - &mu;) / &mu; * 100
% 'bl', ...  % DC offset correction:    x_std = x - &mu;
% 'divmean', ...  % Scale with the mean:    x_std = x / &mu;
% 'db', ...  % Scale with the mean (dB):    x_std = 10 * log10(x / &mu;)
% 'contrast', ...  % Contrast with the mean:    x_std = (x - &mu;) / (x + &mu;)








project.brainstorm.tf.gb.aggregate_func = 'mean';
project.brainstorm.tf.gb.isfreqbands = 1;% enable group frequency bands

% project.brainstorm.tf.gb.freqbands = {'delta', '2, 4', 'mean'; 'theta', '5, 7', 'mean'; 'alpha', '8, 12', 'mean'; 'beta', '15, 29', 'mean'};
tb = length(project.postprocess.ersp.frequency_bands);
tc = 3; % colums: name, timits, aggregate function
project.brainstorm.tf.gb.freqbands = cell(tb,tc);
for nb = 1:tb
    project.brainstorm.tf.gb.freqbands{nb,1} = project.postprocess.ersp.frequency_bands(nb).name;
    project.brainstorm.tf.gb.freqbands{nb,2} = [num2str(project.postprocess.ersp.frequency_bands(nb).min),', ' , num2str(project.postprocess.ersp.frequency_bands(nb).max)];
    project.brainstorm.tf.gb.freqbands{nb,3} = project.brainstorm.tf.gb.aggregate_func;    
end


project.brainstorm.tf.gb.istimebands = 1; % enable group time bands


%project.brainstorm.tf.gb.timebands = {'t0', '-200, 0', 'mean'; 't1', '0, 100', 'mean'; 't2', '100, 200', 'mean'; 't3', '200, 300', 'mean'; 't4', '15, 29', 'mean'};
tb = length(project.postprocess.ersp.design(1).group_time_windows);
tc = 3; % colums: name, timits,aggregate function
project.brainstorm.tf.gb.timebands = cell(tb,tc);
for nb = 1:tb
    project.brainstorm.tf.gb.timebands{nb,1} = project.postprocess.ersp.design(1).group_time_windows(nb).name;
    project.brainstorm.tf.gb.timebands{nb,2} = [num2str(project.postprocess.ersp.design(1).group_time_windows(nb).min),', ' , num2str(project.postprocess.ersp.design(1).group_time_windows(nb).max)];
    project.brainstorm.tf.gb.timebands{nb,3} = project.brainstorm.tf.gb.aggregate_func;    
end



%% TIME FREQUENCY ANALYSIS

% Morlet wavelet
project.brainstorm.tf.Freqs = project.study.ersp.freqout_analysis_interval;
project.brainstorm.tf.MorletFc = 1;% central frequency of Morlet wavelet function (Hz)
project.brainstorm.tf.MorletFwhmTc = 3; % time resolution (FWHM) (sec)
project.brainstorm.tf.RemoveEvoked = 1;
project.brainstorm.tf.normalize = 'none'; % 'none' | 'multiply':1/f compensation: Multiply output values by frequency
project.brainstorm.tf.measure = 'power';% %'magnitude' | 'power'
project.brainstorm.tf.output  = 'average'; % 'average' recommended | 'all' save alla files, requires uge amount of space 
project.brainstorm.tf.ClusterFuncTime = 'after'; % 'after' | 'before' compute tf with respect to cluter sources

% baseline correction
project.brainstorm.tf.bc.baseline = [project.epoching.bc_st.s, project.epoching.bc_end.s];
project.brainstorm.tf.bc.method = 'db';

% % group time and frequenncy bands
% project.brainstorm.tf.gb.isfreqbands = 1;% enable group frequency bands
% project.brainstorm.tf.gb.freqbands = {'delta', '2, 4', 'mean'; 'theta', '5, 7', 'mean'; 'alpha', '8, 12', 'mean'; 'beta', '15, 29', 'mean'};
% project.brainstorm.tf.gb.istimebands = 1; % enable group time bands
% project.brainstorm.tf.gb.timebands = {'t0', '-200, 0', 'mean'; 't1', '0, 100', 'mean'; 't2', '100, 200', 'mean'};

project.brainstorm.tf.gb.aggregate_func = 'mean';
project.brainstorm.tf.gb.isfreqbands = 1;% enable group frequency bands

% project.brainstorm.tf.gb.freqbands = {'delta', '2, 4', 'mean'; 'theta', '5, 7', 'mean'; 'alpha', '8, 12', 'mean'; 'beta', '15, 29', 'mean'};
tb = length(project.postprocess.ersp.frequency_bands);
tc = 3; % colums: name, timits, aggregate function
project.brainstorm.tf.gb.freqbands = cell(tb,tc);
for nb = 1:tb
    project.brainstorm.tf.gb.freqbands{nb,1} = project.postprocess.ersp.frequency_bands(nb).name;
    project.brainstorm.tf.gb.freqbands{nb,2} = [num2str(project.postprocess.ersp.frequency_bands(nb).min),', ' , num2str(project.postprocess.ersp.frequency_bands(nb).max)];
    project.brainstorm.tf.gb.freqbands{nb,3} = project.brainstorm.tf.gb.aggregate_func;    
end


project.brainstorm.tf.gb.istimebands = 1; % enable group time bands


%project.brainstorm.tf.gb.timebands = {'t0', '-200, 0', 'mean'; 't1', '0, 100', 'mean'; 't2', '100, 200', 'mean'; 't3', '200, 300', 'mean'; 't4', '15, 29', 'mean'};
tb = length(project.postprocess.ersp.design(1).group_time_windows);
tc = 3; % colums: name, timits,aggregate function
project.brainstorm.tf.gb.timebands = cell(tb,tc);
for nb = 1:tb
    project.brainstorm.tf.gb.timebands{nb,1} = project.postprocess.ersp.design(1).group_time_windows(nb).name;
    project.brainstorm.tf.gb.timebands{nb,2} = [num2str(project.postprocess.ersp.design(1).group_time_windows(nb).min),', ' , num2str(project.postprocess.ersp.design(1).group_time_windows(nb).max)];
    project.brainstorm.tf.gb.timebands{nb,3} = project.brainstorm.tf.gb.aggregate_func;    
end


project.brainstorm.tf.scout_tag_list                = {'sloreta | free | surf',...
                                        };
 

                                    
 %% FUNCTIONAL CONNECTIVITY

project.brainstorm.fc.scout_tag_list                = {'sloreta | free | surf',...
                                        };

project.brainstorm.fc.standard_measure_list = {...
    'corr1n',...                 % Process: Correlation NxN
    'corr1n_time',...            % Process: Time-resolved correlation NxN [test]
    'cohere1n',...               % Process: Coherence NxN
    'cohere1n_time',...          % Process: Time-resolved coherence NxN [test]
    'granger1n',...              % Process: Bivariate Granger causality NxN
    'spgranger1n',...            % Process: Bivariate Granger causality (spectral) NxN
    'plv1n',...                  % Process: Phase locking value NxN SUPPORTED ONLY FOR CONTRAINED SOURCES
    'pte1n',...                  % Process: Phase Transfer Entropy NxN
    'aec1n',...                  % Process: Amplitude Envelope Correlation NxN 
    'pac',...                    % Process: Phase-amplitude coupling
    'tpac',...                   % Process: tPAC 
    'canoltymap',...             % Process: Canolty maps
    };

project.brainstorm.fc.selected_measure_list = ...
    project.brainstorm.fc.standard_measure_list(5);

% Process: Correlation NxN
project.brainstorm.fc.corr1n.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.corr1n.outputmode = 1; % Save individual results (one file per input file)
project.brainstorm.fc.corr1n.scalarprod = 0; % 0 = Normalized

% Process: Time-resolved correlation NxN [test]
project.brainstorm.fc.corr1n.scouttime= 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.corr1n.scalarprod = 0;% 0 = Normalized
project.brainstorm.fc.corr1n.outputmode= 1; % Save individual results (one file per input file)



% Process: Coherence NxN  
project.brainstorm.fc.cohere1n.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.cohere1n.removeevoked = 0; % 0 = compute without removing evoked response (ERP)| 1 = after removing ERP 
project.brainstorm.fc.cohere1n.cohmeasure = 1; % 1 = Magnitude-squared
project.brainstorm.fc.cohere1n.outputmode = 1; % Save individual results (one file per input file)

% Process: Time-resolved coherence NxN [test]
project.brainstorm.fc.cohere1n_time.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.cohere1n_time.removeevoked = 0; % 0 = compute without removing evoked response (ERP)| 1 = after removing ERP 
project.brainstorm.fc.cohere1n_time.cohmeasure = 1; % 1 = Magnitude-squared
% project.brainstorm.fc.cohere1n_time.outputmode = 1; % Save individual results (one file per input file)
project.brainstorm.fc.cohere1n_time.win = 0.1;
project.brainstorm.fc.cohere1n_time.overlap = 50;


% Process: Bivariate Granger causality NxN
project.brainstorm.fc.granger1n.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.granger1n.removeevoked = 0; % 0 = compute without removing evoked response (ERP)| 1 = after removing ERP 
project.brainstorm.fc.granger1n.outputmode = 1; % Save individual results (one file per input file)

% Process: Bivariate Granger causality (spectral) NxN
project.brainstorm.fc.spgranger1n.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.spgranger1n.removeevoked = 0; % 0 = compute without removing evoked response (ERP)| 1 = after removing ERP 
project.brainstorm.fc.spgranger1n.outputmode = 1; % Save individual results (one file per input file)
                                    
% Process: Phase locking value NxN                                    
project.brainstorm.fc.plv1n.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.plv1n.freqbands = project.brainstorm.tf.gb.freqbands;
project.study.fc.plv1n.mirror = 0;
project.study.fc.plv1n.keeptime = 1;
project.study.fc.plv1n.plvmeasure = 2;
project.brainstorm.fc.plv1n.outputmode = 1; % Save individual results (one file per input file)
    
% Process: Phase Transfer Entropy NxN
project.brainstorm.fc.pte1n.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.pte1n.freqbands = project.brainstorm.tf.gb.freqbands;
project.study.fc.pte1n.mirror = 0;
project.study.fc.pte1n.normalized = 1;
project.brainstorm.fc.pte1n.outputmode = 1; % Save individual results (one file per input file)



% Process: Amplitude Envelope Correlation NxN
project.brainstorm.fc.aec1n.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.aec1n.freqbands = project.brainstorm.tf.gb.freqbands;
project.brainstorm.fc.aec1n.isorth = 0;
project.brainstorm.fc.aec1n.outputmode = 1; % Save individual results (one file per input file)


% Process: Phase-amplitude coupling
project.brainstorm.fc.pac.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.pac.outputmode = 1; % Save individual results (one file per input file)
project.brainstorm.fc.pac.scalarprod = 0; % 0 = Normalized
project.brainstorm.fc.pac.nesting = [2, 30];
project.brainstorm.fc.pac.nested =  [40, 150];
project.brainstorm.fc.pac.numfreqs = 0;
project.brainstorm.fc.pac.parallel = 0;
project.brainstorm.fc.pac.ismex = 1;
project.brainstorm.fc.pac.max_block_size = 1;
project.brainstorm.fc.pac.avgoutput = 0;
project.brainstorm.fc.pac.savemax = 0;
    
% Process: tPAC
project.brainstorm.fc.tpac.scouttime = 2; % 1 = compute before scout grouping  | 2 = After
project.brainstorm.fc.tpac.outputmode = 1; % Save individual results (one file per input file)
project.brainstorm.fc.tpac.scalarprod = 0; % 0 = Normalized
project.brainstorm.fc.tpac.nesting = [2, 30];
project.brainstorm.fc.tpac.nested =  [40, 150];
project.brainstorm.fc.tpac.fa_type = 2;
project.brainstorm.fc.tpac.winLen = 1.1;
project.brainstorm.fc.tpac.target_res = '';
project.brainstorm.fc.tpac.max_block_size = 1;
project.brainstorm.fc.tpac.avgoutput = 0;
project.brainstorm.fc.tpac.margin = 1;

%%
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------
% GROUP ANALYSIS
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------

list_select_groups = {};  %{ 'AS', 'AEB'} cell array to select groups to be analyzed project.subjects.group_names

if not(exist('list_select_groups','var'))
    list_select_groups    = project.subjects.group_names;
else
    if isempty(list_select_groups) 
        list_select_groups    = project.subjects.group_names;
    end
end

project.brainstorm.groupanalysis.vec_select_groups  = find(ismember(project.subjects.group_names,  list_select_groups));


project.brainstorm.baselineanalysis.comparisons         = project.epoching.condition_names;     
project.brainstorm.baselineanalysis.baseline            = [project.epoching.bc_st.s, project.epoching.bc_end.s];
project.brainstorm.baselineanalysis.poststim            = [0.05, project.epoching.epo_end.s];

project.brainstorm.groupanalysis.comment                = [];
project.brainstorm.groupanalysis.data_type              = 'results_'; 
project.brainstorm.groupanalysis.abs_type               = 0;  ... never normalize during z-transform
project.brainstorm.groupanalysis.analysis_type          = 'wmne_fixed_surf_zscore'; %'wmne_free_surf_zscore_norm';
project.brainstorm.groupanalysis.interval               = [0 project.epoching.epo_end.s];
project.brainstorm.groupanalysis.pairwise_comparisons   = project.brainstorm.sensors.pairwise_comparisons;
project.brainstorm.groupanalysis.analysis_type_list     = {'sloreta_free_surf_norm', 'sloreta_free_surf_tw_average_C1_norm', 'sloreta_free_surf_tw_average_P140_norm','sloreta_free_surf_tw_average_ACOP_norm'};
project.brainstorm.groupanalysis.averaging_continuous_list = {'sloreta_free_surf_norm'};
project.brainstorm.groupanalysis.averaging_tw_list = { 'sloreta_free_surf_tw_average_C1_norm', 'sloreta_free_surf_tw_average_P140_norm','sloreta_free_surf_tw_average_ACOP_norm'};

project.brainstorm.groupanalysis.compare_conds_within_group          = 1;
project.brainstorm.groupanalysis.compare_groups_within_cond          = 1;


% group_comparison_analysis_type_list  = {'sloreta_free_surf_norm', 'sloreta_free_surf_tw_average_C1_norm', 'sloreta_free_surf_tw_average_P140_norm','sloreta_free_surf_tw_average_ACOP_norm'};
% 
% group_results_averaging_continuous_list = {'sloreta_free_surf_norm'};
% group_results_averaging_tw_list = { 'sloreta_free_surf_tw_average_C1_norm', 'sloreta_free_surf_tw_average_P140_norm','sloreta_free_surf_tw_average_ACOP_norm'};
 
 



%% --------------------------------------------------------------------------------------------------------------------------------------------------------------------
% STATS
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------

project.brainstorm.stats.pvalue                         = 0.05;
project.brainstorm.stats.correction                     = 'fdr';
project.brainstorm.stats.num_permutations               = 1000;
project.brainstorm.stats.ttest_abstype                  = 1;
project.brainstorm.stats.correction_dimension           = 'space';
project.brainstorm.stats.method                         = 'parametric';% 'non-parametric'|'parametric'


%% --------------------------------------------------------------------------------------------------------------------------------------------------------------------
% RESULTS POSTPROCESS & EXPORT
%--------------------------------------------------------------------------------------------------------------------------------------------------------------------

% substring used to get and process specific results file
project.brainstorm.results_processing.process_result_string='twalker_cwalker_wmne_free_surf_tw_average_5_samples_Uniform250';     

project.brainstorm.export.scout_name_inputfile   = ['wmne_free_surf_zscore_norm_scouts' '_' strjoin2(project.brainstorm.postprocess.scouts_names, '_')]; 
project.brainstorm.export.scout_name_outputfile   = ['wmne_free_surf_zscore_norm_scouts' '_' strjoin2(project.brainstorm.postprocess.scouts_names, '_') '_' strjoin2({project.brainstorm.postprocess.group_time_windows.name}, '_')]; 


project.brainstorm.export.spm_vol_downsampling          = 2;
project.brainstorm.export.spm_time_downsampling         = 1;


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
project.epoching.bc_st.ms   = project.epoching.bc_st.s*1000;            % baseline correction start latency
project.epoching.bc_end.ms  = project.epoching.bc_end.s*1000;           % baseline correction end latency
project.epoching.epo_st.ms  = project.epoching.epo_st.s*1000;             % epochs start latency
project.epoching.epo_end.ms = project.epoching.epo_end.s*1000;             % epochs end latency

% project.epoching.baseline_mark.baseline_begin_target_marker_delay.ms = project.epoching.baseline_mark.baseline_begin_target_marker_delay.s *1000; % delay  between target and baseline begin marker to be inserted

%  ********* /DERIVED DATA *****************************************************************


% ======================================================================================================
% POSTPROCESS
% ======================================================================================================

%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
for fb=1:length(project.postprocess.ersp.frequency_bands)
    project.postprocess.eeglab.frequency_bands_list{fb,1}=[project.postprocess.ersp.frequency_bands(fb).min,project.postprocess.ersp.frequency_bands(fb).max];
end
project.postprocess.eeglab.frequency_bands_names = {project.postprocess.ersp.frequency_bands.name};%  ********* /DERIVED DATA  *****************************************************************


% ERP
%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
project.study.erp.tmin_analysis.ms                  = project.study.erp.tmin_analysis.s*1000;
project.study.erp.tmax_analysis.ms                  = project.study.erp.tmax_analysis.s*1000;
project.study.erp.ts_analysis.ms                    = project.study.erp.ts_analysis.s*1000;
project.study.erp.timeout_analysis_interval.ms      = project.study.erp.timeout_analysis_interval.s*1000;
%  ********* /DERIVED DATA  *****************************************************************


% ERSP
%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
project.study.ersp.tmin_analysis.ms                 = project.study.ersp.tmin_analysis.s*1000;
project.study.ersp.tmax_analysis.ms                 = project.study.ersp.tmax_analysis.s*1000;
project.study.ersp.ts_analysis.ms                   = project.study.ersp.ts_analysis.s*1000;
project.study.ersp.timeout_analysis_interval.ms     = project.study.ersp.timeout_analysis_interval.s*1000;
%  ********* /DERIVED DATA  *****************************************************************


% ======================================================================================================
% RESULTS DISPLAY
% ======================================================================================================
      
%  ********* DERIVED DATA : DO NOT EDIT *****************************************************************
project.results_display.erp.time_range.ms           = project.results_display.erp.time_range.s*1000;
project.results_display.ersp.time_range.ms          = project.results_display.ersp.time_range.s*1000;
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
% eeglab_derived_parameters_project(project)

%% import additional subject parameters from external excel file
%        mark subject column with 'subject' |  'soggetto' |  'subj' |  'sub' NO case sensitive;

project.external_xls.xls_folder = '';
project.external_xls.xls_file = '';
project.external_xls.xls_sheet = '';
project = project_import_external_xls(project);

