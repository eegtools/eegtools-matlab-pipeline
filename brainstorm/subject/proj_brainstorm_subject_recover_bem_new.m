
function proj_brainstorm_subject_recover_bem_new(project, varargin)

iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;


list_select_subjects    = project.subjects.list;


for par=1:2:length(varargin)
    switch varargin{par}
        case { 'list_select_subjects', ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end



ProtocolSubjects    = bst_get('ProtocolSubjects');
%     subj1_name          = ProtocolSubjects.Subject(1).Name;

ind1 = 1;
subj1_name          = ProtocolSubjects.Subject(ind1).Name;


if strcmp(subj1_name, 'Group_analysis')
    ind1 = 2;
    subj1_name          = ProtocolSubjects.Subject(ind1).Name;
    
end


bck_dir             = fullfile(project.paths.project,'bck_bem');


bck_file_list        = {project.brainstorm.conductorvolume.bem_file_name,...
    'channel.mat'
    };


if not(exist(bck_dir,'dir'))
    disp('no bem backup available')
else
    
    

    
    for subj=1:length(list_select_subjects)
        
        dest_dir = fullfile(project.paths.brainstorm_data, list_select_subjects{subj},'@default_study');
        
        
        for nf = 1:length(bck_file_list)
            
            src_file  = fullfile(bck_dir, bck_file_list{nf});
            dest_file = fullfile(dest_dir, bck_file_list{nf});
            
            copyfile(src_file, dest_file);
        end
        
        
    end
    db_reload_database(iProtocol);
end
db_reload_database(iProtocol);

end

