... model_type 1: surface, 2: vol
    function brainstorm_subject_check_bem_new(project)

iProtocol               = brainstorm_protocol_open(protocol_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

ProtocolSubjects    = bst_get('ProtocolSubjects');
%     subj1_name          = ProtocolSubjects.Subject(1).Name;

ind1 = 1;
subj1_name          = ProtocolSubjects.Subject(ind1).Name;


if strcmp(subj1_name, 'Group_analysis')
    ind1 = 2;
    subj1_name          = ProtocolSubjects.Subject(ind1).Name;
    
end

src_file            = fullfile(project.paths.brainstorm_data, subj1_name,'@default_study', project.brainstorm.conductorvolume.bem_file_name);

for subj=1:length(list_select_subjects);
    dest_file = fullfile(project.paths.brainstorm_data, list_select_subjects{subj},'@default_study', project.brainstorm.conductorvolume.bem_file_name);
    if  not(file_exist(dest_file)) %not(subj == ind1) &&
        copyfile(src_file, dest_file);
    end
end
db_reload_database(iProtocol);

    end
    
