%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_ica(project, varargin)

    list_select_subjects    = project.subjects.list;

    options_num             = size(varargin,2);
    for opt=1:2:options_num    
        switch varargin{opt}
            case 'list_select_subjects'
                list_select_subjects    = varargin{opt+1};
            case 'custom_suffix'
                 custom_suffix          = varargin{opt+1};
        end
    end
    
    if not(iscell(list_select_subjects)), list_select_subjects = {list_select_subjects}; end
    numsubj = length(list_select_subjects);

    for subj=1:numsubj
        
        subj_name   = list_select_subjects{subj}; 
        inputfile   = proj_eeglab_subject_get_filename(project, subj_name, 'custom_pre_epochs', 'custom_suffix', custom_suffix);
        EEG         = eeglab_subject_ica(inputfile, project.paths.output_preprocessing, project.eegdata.eeg_channels_list, project.import.reference_channels, 'cudaica');    
    
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