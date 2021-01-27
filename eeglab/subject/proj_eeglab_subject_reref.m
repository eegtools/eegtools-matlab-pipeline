%% EEG = proj_eeglab_subject_reref(project, varargin)
%
function EEG = proj_eeglab_subject_reref(project, varargin)

list_select_subjects    = project.subjects.list;
get_filename_step       = 'input_epoching';
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
    match_ref = [];
    subj_name   = list_select_subjects{subj};
    inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
    [folder, name_noext, ext] = fileparts(inputfile );
    
    EEG         = pop_loadset(inputfile);
    
    
    
    acquisition_system    = project.import.acquisition_system;
    montage_list          = project.preproc.montage_list;
    montage_names         = project.preproc.montage_names;
    
    
    select_montage         = ismember(montage_names,acquisition_system);
    ch_montage             = montage_list{select_montage};
    
    
      
    dataset_ch_lab = {EEG.chanlocs.labels};
    dataset_eeg_ch_lab = intersect(dataset_ch_lab,ch_montage);
    nch_eeg_dataset = length(dataset_eeg_ch_lab);
    exclude = [];    
    if EEG.nbchan > nch_eeg_dataset 
        exclude = (nch_eeg_dataset+1) : EEG.nbchan;
    end
    
    if not(isfield(EEG,'reref'))
        
        
        EEG = pop_saveset( EEG, 'filename',[name_noext,'_rerefbck',ext],'filepath',EEG.filepath);
        
        EEG.reref = 1;

        reference   = [];
        
        tchanref = length(project.import.reference_channels);
        channels_list   = {EEG.chanlocs.labels};
        tch = length(channels_list);
        channels_ind = 1:tch;
        
        if not(strcmp(project.import.reference_channels{1}, 'CAR'))
            
            
            for nchref=1:tchanref;
                ll                  = length(project.import.reference_channels{nchref});
                match_ref(nchref,:) = strncmp(channels_list, project.import.reference_channels(nchref), ll);
            end
            refvec      = find(sum(match_ref,1)>0);
            reference   = refvec;
        end
        
%         exclude = find(channels_ind > project.eegdata.nch_eeg);
        
        EEG = pop_reref(EEG, [reference], 'keepref', 'on','exclude',[exclude]);
%         EEG = pop_reref( EEG, [16 50] ,'exclude',[60 61] ,'keepref','on');

        
        EEG = eeg_checkset( EEG );
        EEG = pop_saveset( EEG, 'filename', [name_noext,ext],'filepath',EEG.filepath);
        
    else
        disp('data already re-referenced!!!!!')
        return
    end
    
    
    
end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name
