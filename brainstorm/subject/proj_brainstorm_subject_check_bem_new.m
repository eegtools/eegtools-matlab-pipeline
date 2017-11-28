... model_type 1: surface, 2: vol
    function proj_brainstorm_subject_check_bem_new(project)

iProtocol               = brainstorm_protocol_open(protocol_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

ProtocolSubjects    = bst_get('ProtocolSubjects');
%     subj1_name          = ProtocolSubjects.Subject(1).Name;

list_subjects       =  {ProtocolSubjects.Subject.Name};

ind_Group_analysis = find(ismember(list_subjects,'Group_analysis'));

if isempty(exist_Group_analysis)
    ind1 = 1;
else
    if ind_Group_analysis == 1
    ind1 = 2;
    else
        disp('miiiiiii hai assunto male!');
        return
    end
end



subj1_name = list_subjects(ind1);

src_file            = fullfile(project.paths.brainstorm_data, subj1_name,'@default_study', project.brainstorm.conductorvolume.bem_file_name);

for subj=(ind1+1):length(ProtocolSubjects);
    dest_file = fullfile(project.paths.brainstorm_data, ProtocolSubjects{subj},'@default_study', project.brainstorm.conductorvolume.bem_file_name);
    if  not(file_exist(dest_file)) %not(subj == ind1) &&
        copyfile(src_file, dest_file);
    end
end
db_reload_database(iProtocol);

    end
    
