%% EEG = proj_eeglab_subject_preprocessing(project, varargin)
%
% function to preprocess already imported and filtered data
%
% SUBSAMPLING
% CHANNELS TRANSFORMATION
% INTERPOLATION
% EVENT FILTERING
% SPECIFIC FILTERING
%
%%
function EEG = proj_eeglab_subject_sleep_analysis_hume(project, varargin)


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

%% copy forked functions into hume directory (to recover, remove and git pull)

% hume
project.paths.plugin.hume              = fullfile(project.paths.plugins_root, 'hume', 'Hume');
addpath(project.paths.plugin.hume);
hume;

spectrogramRpt_SingleCh_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['spectrogramRpt_SingleCh.m']);
spectrogramRpt_SingleChdir_hume = fullfile(project.paths.plugin.hume,'gui');
copyfile(spectrogramRpt_SingleCh_m,spectrogramRpt_SingleChdir_hume);


detectSW_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['detectSW.m']);
detectSWdir_hume = fullfile(project.paths.plugin.hume,'coreFunctions','detectionFunctions');
copyfile( detectSW_m,detectSWdir_hume);


detectSpindles_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['detectSpindles.m']);
detectSpindlesdir_hume = fullfile(project.paths.plugin.hume,'coreFunctions','detectionFunctions');
copyfile( detectSpindles_m,detectSWdir_hume);


SWSpiCoupling_m = fullfile(project.paths.framework_root,'eeg_tools','utilities',['SWSpiCoupling.m']);
detectSpindlesdir_hume = fullfile(project.paths.plugin.hume,'coreFunctions','detectionFunctions');
copyfile( SWSpiCoupling_m,detectSWdir_hume);




for subj=1:numsubj
    
    subj_name               = list_select_subjects{subj};
    input_file_name         = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    disp(input_file_name);
    
    if exist(input_file_name)
        try
            EEG                     = pop_loadset(input_file_name);
        catch
            [fpath,fname,fext] = fileparts(input_file_name);
            EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
        end
    else
        disp('no such file!');
    end
    
    
    stagedatadir = fullfile(project.paths.project, 'hume');
    stagedata_path = fullfile(stagedatadir,[EEG.filename(1:end-4),'.mat']);
    load(stagedata_path);
    
    
    % creo campi custom per gestire parametri
    stageData.Flims_global = project.sleep.hume.stageData.Flims_global;%[.05 20];
    stageData.Flims_delta = project.sleep.hume.stageData.Flims_delta;%[.5 4.75];
    stageData.Flims_sigma = project.sleep.hume.stageData.Flims_sigma;%[.05 20];
    stageData.project = project;
    stageData.spect_win = project.sleep.hume.stageData.spect_win;% wi
    
    
    %% sleep analysis using hume functions
    all_output = [];
    if(not((project.sleep.hume.reset_detection)))
        if isfield(stageData,'rectEvents')
            all_output =  stageData.rectEvents;
        end
    end
    
    tot_ch_spindles = length(project.sleep.hume.detectSpindles.channelLabels);
    for nch = 1:tot_ch_spindles
        % detect sleep spindles
        current_ch = project.sleep.hume.detectSpindles.channelLabels{nch};
        if sum(ismember({EEG.chanlocs.labels},current_ch))
            [output, ~] = detectSpindles(stageData, EEG, current_ch);
            all_output = [all_output;output];
        end
    end
    stageData.rectEvents = all_output;
    
    save(stagedata_path,'stageData');
    
    
    
    % detect slow waves
    %     [output perEventData] = detectSW(stageData, EEG, ch);
    
    all_output = [];
    if(not((project.sleep.hume.reset_detection)))
        if isfield(stageData,'rectEvents')
            all_output =  stageData.rectEvents;
        end
    end
    tot_ch_detectSW = length(project.sleep.hume.detectSW.channelLabels);
    for nch = 1:tot_ch_detectSW
        % detect sleep spindles
        current_ch = project.sleep.hume.detectSW.channelLabels{nch};
        if sum(ismember({EEG.chanlocs.labels},current_ch))
            [output, ~] = detectSW(stageData, EEG, current_ch);
            all_output = [all_output;output];
        end
    end
    stageData.rectEvents = all_output;
    
    save(stagedata_path,'stageData');
    
    
    if project.sleep.hume.SWSpiCoupling.enable        
        tot_nch_coupling = length(project.sleep.hume.SWSpiCoupling.channelLabels);        
        for nchc = 1:tot_nch_coupling
            current_ch = project.sleep.hume.SWSpiCoupling.channelLabels{nchc};
            if sum(ismember({EEG.chanlocs.labels},current_ch))
                spiEvent = ['Sleep Spindle (Ferrarelli/Warby ', current_ch,')'];
                swEvent = ['Slow Wave (Riedner/Massimini)', current_ch,')'];
                [out] = SWSpiCoupling(stageData, EEG, current_ch, spiEvent, swEvent);
                plotfile_path = fullfile(stagedatadir,[EEG.filename(1:end-4),'_',current_ch,'.fig']);
                savefig(out,plotfile_path);
            end
%             close all
        end
    end
    
    % spectrogram
    stageStatsdir = fullfile(project.paths.project, 'hume',EEG.filename(1:end-4));
    stageStats_path = fullfile(stageStatsdir,[EEG.filename(1:end-4),'_stats.mat']);
    load(stageStats_path);
    
    
     % creo campi custom per gestire parametri
    stageStats.stageData.Flims_global = project.sleep.hume.stageData.Flims_global;%[.05 20];
    stageStats.stageData.Flims_delta = project.sleep.hume.stageData.Flims_delta;%[.5 4.75];
    stageStats.stageData.Flims_sigma = project.sleep.hume.stageData.Flims_sigma;%[.05 20];
    stageStats.stageData.project = project;
    stageStats.stageData.spect_win = project.sleep.hume.stageData.spect_win;% wi
    
    save(stageStats_path,'stageStats');

    
    
    tot_ch_spectrogram = length(project.sleep.hume.spectrogram.channelLabels);
    for nch = 1:tot_ch_spectrogram
        % compute spectrogram
        current_ch = project.sleep.hume.spectrogram.channelLabels{nch};
        if sum(ismember({EEG.chanlocs.labels},current_ch))
%             h0 = spectrogramRpt_SingleCh(EEG,current_ch, stageStats);
            h0 = spectrogramRpt_SingleCh_mean_norm(EEG,current_ch, stageStats);
            h1 = spectrogramRpt_SingleCh_sum_norm(EEG,current_ch, stageStats);
            
            close all
        end
    end
    
end
end
