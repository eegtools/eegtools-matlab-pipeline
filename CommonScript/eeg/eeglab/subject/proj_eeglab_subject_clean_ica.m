%% EEG = proj_eeglab_subject_clean_ica(project, varargin)
%  funzione per testare/usare come supporto toolbox eeglab che eliminano
% artefatti usando ica (a differenza della pca come nell'algoritmo di ASR)
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_clean_ica(project, varargin)


    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'custom_pre_epochs';
    custom_suffix           = '';
    custom_input_folder     = '';
    
    if isfield(project,'ica_type')
        ica_type = project.ica_type;
    else
        ica_type = 'cudaica';
    end
    
    for par=1:2:length(varargin)
        switch varargin{par}
            case {  ...
                    'list_select_subjects', ...
                    'get_filename_step',    ... 
                    'custom_input_folder',  ...
                    'custom_suffix' ...
                    };

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

%     names = {};
%     durations = {};
%     ranks = {};
%     ica_types ={};
    
    for subj=1:numsubj
        
        subj_name   = list_select_subjects{subj}; 
        inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
                     
        [fname, EEG]         = eeglab_subject_clean_ica(inputfile, project.paths.output_preprocessing);    
   
    end
    
%     summary = [names; ranks; ica_types; durations]';
%     disp(summary);
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 29/12/2014
% the function now accept also a cell array of subject names, instead of a single subject name
% utilization of proj_eeglab_subject_get_filename function to define IO file name