%% EEG = proj_eeglab_subject_newchannel_difference(project, varargin)
%
%%
function EEG = proj_eeglab_subject_newchannel_difference(project, varargin)

    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'add_factor';
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
        
        EEG                     = eeglab_subject_newchannel_difference(input_file_name, 'hEye', 'AF7', 'AF8');
    end
end
% ====================================================================================================
% ====================================================================================================
% CHANGE LOG
% ====================================================================================================
% ====================================================================================================
% 28/05/2015
% first version