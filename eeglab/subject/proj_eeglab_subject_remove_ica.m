%% EEG = proj_eeglab_subject_ica(project, varargin)
%
% typically custom_suffix is
% 1) ''    : it makes ICA over pre-processed data
% 2) '_sr' : it makes ICA over data after segments removal
%
%%
function EEG = proj_eeglab_subject_remove_ica(project, varargin)

		

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
    vsel_sub = find(ismember(project.subjects.list,list_select_subjects));
    
    % -------------------------------------------------------------------------------------------------------------------------------------

%     names = {};
%     durations = {};
%     ranks = {};
%     ica_types ={};
    
    for subj=1:numsubj
        sel_sub = vsel_sub(subj);
        subj_name   = list_select_subjects{subj}; 
        inputfile   = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        ic2remove = [project.subjects.data(sel_sub).bad_ic{:}];

        if isempty(ic2remove)
            EEG = [];
            disp(['not removing any ic ','from',  inputfile])
        else
            disp(['removing ic ' ,num2str(ic2remove) ,' from',  inputfile])
            EEG         = eeglab_subject_remove_ica(inputfile,ic2remove);
        end
   
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
