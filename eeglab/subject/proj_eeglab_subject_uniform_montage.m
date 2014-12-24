function EEG = proj_eeglab_subject_uniform_montage(project, subj_name)

inputfile = fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix pre_epoching_input_file_name '.set']);
EEG       = eeglab_subject_uniform_montage(inputfile, project.preproc.montage_list, project.eegdata.eeglab_channels_file_path);

end
