function EEG_NEW = proj_eeglab_subject_merge_conditions(project, subj_name, conditions, new_name)
    

    output_epochs  = project.paths.output_epochs;
    % ----------------------------------------------------------------------------------------------------------------------------
    input_file_name1    = fullfile(output_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' conditions{1} '.set']);
    input_file_name2    = fullfile(output_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' conditions{2} '.set']);
    new_name            = [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' new_name '.set'];

    EEG1                = pop_loadset(input_file_name1);
    EEG2                = pop_loadset(input_file_name2);

    EEG_NEW             = pop_mergeset( EEG1, EEG2, 1);
    EEG_NEW             = pop_saveset( EEG_NEW, 'filename', new_name, 'filepath', output_epochs);
            
end    
