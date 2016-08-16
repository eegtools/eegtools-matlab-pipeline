function EEG  =  proj_eeglab_subject_check_mc(project, varargin)

    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'input_epoching';
    custom_suffix           = '';
    custom_input_folder     = '';
    skip_errors             = 0;
    
    for par=1:2:length(varargin)
        switch varargin{par}
            case {  ...
                    'list_select_subjects', ...
                    'get_filename_step',    ... 
                    'custom_input_folder',  ...
                    'custom_suffix', ...
                    'skip_errors' ...
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

    checks.condition_triggers                           = project.task.events.valid_marker;
    
    checks.begin_trial.switch                           = 'on';
    checks.begin_trial.input.begin_trial_marker         = project.task.events.trial_start_trigger_value;
    checks.begin_trial.input.end_trial_marker           = project.task.events.trial_end_trigger_value;

    checks.end_trial.switch                             = 'on';
    checks.end_trial.input.end_trial_marker             = project.task.events.trial_end_trigger_value;
    checks.end_trial.input.begin_trial_marker           = project.task.events.trial_start_trigger_value;

    checks.begin_baseline.switch                        = 'on';
    checks.begin_baseline.input.begin_baseline_marker   = project.task.events.baseline_start_trigger_value;
    checks.begin_baseline.input.end_baseline_marker     = project.task.events.baseline_end_trigger_value;
    
    checks.end_baseline.switch                          = 'on';
    checks.end_baseline.input.begin_baseline_marker     = project.task.events.baseline_start_trigger_value;
    checks.end_baseline.input.end_baseline_marker       = project.task.events.baseline_end_trigger_value;
    checks.end_baseline.input.end_trial_marker          = project.task.events.trial_end_trigger_value;
    
    checks.conditions_triggers                          = project.task.events.mrkcode_cond;
    
    if skip_errors == 1
        checks.begin_trial.switch                           = 'off';
        checks.end_trial.switch                             = 'off';
        checks.begin_baseline.switch                        = 'off';
        checks.end_baseline.switch                          = 'off';        
    end

    for subj=1:numsubj

        subj_name                   = list_select_subjects{subj};
        input_file_name             = proj_eeglab_subject_get_filename(project, subj_name, get_filename_step,'custom_suffix', custom_suffix, 'custom_input_folder', custom_input_folder);
        EEG                         = pop_loadset(input_file_name);

        results                     = eeglab_subject_check_mc(EEG, checks);

    end



end