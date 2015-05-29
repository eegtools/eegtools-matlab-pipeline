function proj_eeglab_subject_plot_ic_tf(project, varargin)


    list_select_subjects    = project.subjects.list;
    get_filename_step       = 'input_epoching';
    custom_suffix           = '';
    custom_input_folder     = '';
    
    output_result_path      = project.paths.results;
    freq_interval           = [];
    subepochs_limits        = [];
    baseline                = [];
    
    for par=1:2:length(varargin)
        switch varargin{par}
            case {  ...
                    'list_select_subjects'  , ...
                    'get_filename_step'     , ... 
                    'custom_input_folder'   , ...
                    'custom_suffix'         , ...
                    'baseline'              , ...
                    'freq_interval'         , ...
                    'subepochs_limits'      , ...
                    'output_result_path'      ...
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

        eeglab_subject_plot_ic_tf(input_file_name, output_result_path, baseline, freq_interval, subepochs_limits, varargin{:})
    end  
end