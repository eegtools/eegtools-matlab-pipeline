function sFiles = brainstorm_group_average_cond_results(db_name, subjects_list, cond_list, input_file_tags)

    iProtocol               = brainstorm_protocol_open(db_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    len_subj                = length(subjects_list);
    len_cond                = length(cond_list);
    
    FileNamesA=cell(1,len_subj);
    
    for ncond=1:len_cond
        cond_name = cond_list{ncond};
        for nsubj=1:len_subj
            FileNamesA{nsubj} = fullfile(subjects_list{nsubj}, cond_name, ['results_' cond_name '_' input_file_tags '.mat']);
        end
        
        % Start a new report
        bst_report('Start', FileNamesA);

        % Process: grand average (by condition) of input results
        sFiles = bst_process(...
            'CallProcess', 'process_average', ...
            FileNamesA, [], ...
            'avgtype', 4, ...  group by condition (grand average)
            'avg_func', 1, ... 
            'keepevents', 1); 

        % Save report
        ReportFile      = bst_report('Save', sFiles);
        if isempty(sFiles)
            bst_report('Open', ReportFile);        
            rep = load(ReportFile);
            rep.Reports{3,4}
           keyboard 
        end 

        % APPLY TAG NAME 
        sFiles = bst_process(...
        'CallProcess', 'process_add_tag', ...
        sFiles, [], ...
        'tag', input_file_tags, ...
        'output', 1);  % Add to comment        
        
        src_filename  = fullfile(brainstorm_data_path, sFiles(1).FileName);
        dest_filename = fullfile(brainstorm_data_path, 'Group_analysis', cond_name, ['results_average_' cond_name '_' input_file_tags '.mat']);
        movefile(src_filename, dest_filename, 'f');    
   
    end
     
    db_reload_studies(sFiles(1).iStudy);
end
