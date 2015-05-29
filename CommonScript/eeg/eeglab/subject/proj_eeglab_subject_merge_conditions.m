function EEG_NEW = proj_eeglab_subject_merge_conditions(project, list_select_subjects, conditions, new_name, varargin)

    get_filename_step       = 'output_epoching';
    custom_suffix           = '';
    custom_input_folder     = '';
    
    for par=1:2:length(varargin)
        switch varargin{par}
            case {  ...
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

        subj_name           = list_select_subjects{subj};
        input_file_name1    = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', conditions{1}, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        input_file_name2    = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', conditions{2}, 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        
        output_file_name    = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step, 'cond_name', new_name     , 'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        [~, new_name, ~]    = fileparts(output_file_name);
        
        EEG1                = pop_loadset(input_file_name1);
        EEG2                = pop_loadset(input_file_name2);

        EEG_NEW             = pop_mergeset(EEG1, EEG2, 1);
        EEG_NEW             = pop_saveset(EEG_NEW, 'filename', new_name, 'filepath', project.paths.output_epochs);        
    end
end    
