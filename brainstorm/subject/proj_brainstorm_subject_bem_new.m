function proj_brainstorm_subject_bem_new(project)


iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

ProtocolSubjects    = bst_get('ProtocolSubjects');
subj1_name          = ProtocolSubjects.Subject(1).Name;

if strcmp(subj1_name, 'Group_analysis')
    subj1_name          = ProtocolSubjects.Subject(2).Name;
end



subj_file_name = fullfile(subj_name, project.epoching.condition_names{1}, 'data_average.mat'); % 'alessandra_finisguerra/cscrambled/data_average.mat', ...
brainstorm_subject_bem_new(project.brainstorm.db_name, subj_file_name);

end

