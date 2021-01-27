function sFiles = brainstorm_group_average_cond_scalp_results2(db_name, group_name,subjects_list, cond_list, input_file_tags)
% questa funzione verrà riscritta facendo 2 importanti modifiche: 1) il
% gruppo e la condizione verranno messi sullo stesso piano; 2) verrà
% agganciata ai disegni definiti nel project structure

    iProtocol               = brainstorm_protocol_open(db_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    len_subj                = length(subjects_list);
    len_cond                = length(cond_list);
    
    FileNamesA=cell(1,len_subj);
    
    for ncond=1:len_cond
        cond_name = cond_list{ncond};
        for nsubj=1:len_subj
            %CLA
%             FileNamesA{nsubj} = fullfile(subjects_list{nsubj}, cond_name, ['data_average_tw_average_ACOP', '.mat']);
            FileNamesA{nsubj} = fullfile(subjects_list{nsubj}, cond_name, [input_file_tags '.mat']);

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

        brainstorm_utility_check_process_success(sFiles);

        % APPLY TAG NAME 
        sFiles = bst_process(...
        'CallProcess', 'process_add_tag', ...
        sFiles, [], ...
        ... CLA 'tag', ['data_average_tw_average_ACOP', '_' group_name], ...
         'tag', [input_file_tags '_' group_name], ...
        'output', 1);  % Add to comment        
        
        src_filename  = fullfile(brainstorm_data_path, sFiles(1).FileName);
        % CLA
%         dest_filename = fullfile(brainstorm_data_path, 'Group_analysis', cond_name, ['results_average_' group_name '_' cond_name '_' 'data_average_tw_average_ACOP' '.mat']);
        dest_filename = fullfile(brainstorm_data_path, 'Group_analysis', cond_name, ['results_average_' group_name '_' cond_name '_' input_file_tags '.mat']);
        movefile(src_filename, dest_filename, 'f');    
   
    end
     
    db_reload_studies(sFiles(1).iStudy);
   
end
