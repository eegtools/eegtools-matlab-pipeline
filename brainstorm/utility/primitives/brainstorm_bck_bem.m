% to do: per ora usare codice nel do_operations2

function dir_bck = brainstorm_bck_bem(list_select_subjects)

if do_check_bem
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
        if not(subj == ind1) && not(file_exist(dest_file))
            copyfile(src_file, dest_file);
        end
    end
    db_reload_database(iProtocol);
end

end

