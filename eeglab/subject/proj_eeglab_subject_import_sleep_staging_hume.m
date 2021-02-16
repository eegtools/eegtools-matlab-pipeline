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
function project = proj_eeglab_subject_import_sleep_staging_hume(project, varargin)


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
    stagedatapath = fullfile(stagedatadir,[EEG.filename(1:end-4),'.mat']);
    disp(stagedatapath);
    if exist(stagedatapath)
        load(stagedatapath);
    else
        disp('no such file!');
    end
    
   
    
    [nr_eeg,nc_eeg] = size(EEG.data);
    
    EEG.pts_win = EEG.srate * stageData.win;
    
    tot_epo = length(stageData.stageTime);
    id_epo = 1:tot_epo;
    
     stadtimes= 1:(tot_epo*EEG.pts_win-1);
%     stadtimes= stageData.onsets(1):(stageData.onsets(end)+EEG.pts_win-1);
    
    allch = {EEG.chanlocs.labels};
    
    stadmat = repmat(stageData.stages',EEG.pts_win,1);
    [nr_stad,nc_stad] = size(stadmat);
    already_staged = sum(ismember(allch, 'SS'));

    if already_staged
        nchstad = nr_eeg;
    else
        nchstad = nr_eeg + 1;
    end
    stadvec = reshape(stadmat,1,nr_stad*nc_stad);
    stadvec(stadvec == 7) = nan; % converto MT in nan
    
    if length(stadtimes)> nc_eeg
        sel_times = stadtimes <= nc_eeg;
        stadtimes = stadtimes (sel_times);
        stadvec = stadvec (sel_times);
    end
    
    
    
    init_stad_ch = nan(1,nc_eeg);
    EEG.data = [EEG.data;init_stad_ch];
    EEG.data(nchstad,stadtimes) = stadvec;
    EEG.chanlocs(nchstad) = EEG.chanlocs(1);
    EEG.chanlocs(nchstad).labels = 'SS';% sleep staging stagingHume
    
    EEG.sleep_stages = project.sleep.hume.stageData.stageNames;
  
    
    EEG = eeg_checkset(EEG);
    eeglab redraw;
    EEG  = pop_saveset( EEG, 'filename', EEG.filename, 'filepath', EEG.filepath);
    
   
    
    
end


end

