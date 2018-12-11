function proj_brainstorm_subject_bem_new(project)

model_type = project.brainstorm.conductorvolume.type; %typical 1

iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;


if not(isfield(project.brainstorm,'condition_names'))
    project.brainstorm.condition_names = project.epoching.condition_names;
    project.brainstorm.numcond         = project.epoching.numcond;
end

ProtocolSubjects    = bst_get('ProtocolSubjects');
subj1_name          = ProtocolSubjects.Subject(1).Name;

if strcmp(subj1_name, 'Group_analysis')
    subj1_name          = ProtocolSubjects.Subject(2).Name;
end



subj_file_name = fullfile(subj1_name, project.brainstorm.condition_names{1}, 'data_average.mat'); % 'alessandra_finisguerra/cscrambled/data_average.mat', ...
brainstorm_subject_bem_new(project.brainstorm.db_name, subj_file_name,model_type);

end

