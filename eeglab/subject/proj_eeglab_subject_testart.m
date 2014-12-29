function EEG = proj_eeglab_subject_testart(project, varargin)   
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
        inputfile = proj_eeglab_subject_get_filename(project, subj_name,'testart');...fullfile(project.paths.input_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix pre_epoching_input_file_name '.set']);
         EEG = eeglab_subject_testart(inputfile, project.paths.input_epochs);
end 
end    
