
function proj_brainstorm_subject_backup_bem_new(project)

protocol_name           = project.brainstorm.db_name;
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

src_dir            = fullfile(project.paths.brainstorm_data, subj1_name,'@default_study');
bck_dir             = fullfile(project.paths.project,'bck_bem');


src_file_list        = {project.brainstorm.conductorvolume.bem_file_name,...
    'channel.mat'
    };




if not(exist(bck_dir,'dir'))
    mkdir(bck_dir)
end

for nf = 1:length(src_file_list)
    
    src_file  = fullfile(src_dir, src_file_list{nf});
    dest_file = fullfile(bck_dir, src_file_list{nf});
    
    copyfile(src_file, dest_file);
end
db_reload_database(iProtocol);

end

