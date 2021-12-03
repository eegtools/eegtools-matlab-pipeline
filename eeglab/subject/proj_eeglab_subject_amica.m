%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_amica(project, varargin)



list_select_subjects    = project.subjects.list;
get_filename_step       = 'custom_pre_epochs';
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

amica_dir = fullfile(project.paths.output_preprocessing,'amica_dir');
if not(exist(amica_dir))
    mkdir(amica_dir);
end


acquisition_system    = project.import.acquisition_system;
montage_list          = project.preproc.montage_list;
montage_names         = project.preproc.montage_names;

select_montage         = ismember(montage_names,acquisition_system);
ch_montage             = montage_list{select_montage};

for subj=1:numsubj
    
    subj_name   = list_select_subjects{subj};
    inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    
    
    try
        EEG                     = pop_loadset(input_file_name);
    catch
        [fpath,fname,fext] = fileparts(input_file_name);
        EEG = pop_loadset('filename',[fname,fext],'filepath',fpath);
    end
    
    % EEG = pop_saveset( EEG, 'filename',[name_noext,'_asrbck',ext],'filepath',path);
    
    dataset_ch_lab = {EEG.chanlocs.labels};
    tch_dataset = length(dataset_ch_lab);
    dataset_eeg_ch_lab = intersect(dataset_ch_lab,ch_montage);
    tch_eeg_dataset = length(dataset_eeg_ch_lab);
    dataset_eeg_ch_list = 1:tch_eeg_dataset;
    
    EEG_amica = EEG;
    
    if tch_eeg_dataset < tch_dataset
        EEG_amica = pop_select(EEG,'channel',dataset_eeg_ch_list);
    end
    
    
    outdir = fullfile(amica_dir, subj_name);
    if not(exist(outdir))
        mkdir(outdir);
    end
    
    
    project_varargin = struct2varargin(project.amica);
    varargin_amica = [{'outdir'}, {outdir}, project_varargin];
    % % add eeglab to path
    % EEG = pop_loadset(‘test_data.set');
    % define parameters
    % numprocs = 1;       % # of nodes
    % max_threads = 1;   % # of threads
    % num_models = 1;     % # of models of mixture ICA
    % max_iter = 1000;    % max number of learning steps
    % run amica
    
    [weights,sphere,mods] = runamica15(EEG_amica.data, varargin_amica{:});
    
    % load EEG data and AMICA results    
    modout = loadmodout15(outdir);
    % load individual ICA model into EEG structure
    model_index = 1;
    EEG_amica.icawinv = modout.A(:,:,model_index);
    EEG_amica.icaweights = modout.W(:,:,model_index);
    EEG_amica.icasphere = modout.S;
    
%     % compute model probability
%     model_prob = 10 .^ modout.v; % modout.v (#models x #samples)
%     figure, imagesc(model_prob(:,1:10*EEG.srate); % model probability changes in first 10s
%     
end

if tch_eeg_dataset < tch_dataset
    for nch = (tch_eeg_dataset + 1):tch_dataset
        EEG_amica.data(nch,:) = EEG.data(nch,:);
        EEG_amica.chanlocs(nch) = EEG.chanlocs(nch);
    end
    eeglab redraw
end



EEG_amica = eeg_checkset(EEG_amica);
EEG_amica = pop_saveset( EEG_amica, 'filename',[fname,fext],'filepath',fpath);

EEG = pop_saveset( EEG_amica, 'filename',[fname,'_icabck',fext],'filepath',fpath);




end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name
