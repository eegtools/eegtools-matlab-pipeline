function EEG = proj_eeglab_subject_ica(project, varargin)

list_select_subjects  = project.subjects.list;


options_num=size(varargin,2);
for opt=1:2:options_num    
    switch varargin{opt}
        case 'list_select_subjects'
            list_select_subjects=varargin{opt+1};
    end
end

numsubj = length(list_select_subjects);

for subj=1:numsubj
    subj_name = list_select_subjects{subj}; 
    inputfile=fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix pre_epoching_input_file_name '.set']);
    EEG = eeglab_subject_ica(inputfile, project.paths.input_epochs, project.eegdata.eeg_channels_list, project.import.reference_channels, 'cudaica');    
end
end
