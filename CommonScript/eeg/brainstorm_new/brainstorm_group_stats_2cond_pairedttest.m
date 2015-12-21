%% function sFiles = brainstorm_group_stats_2cond_pairedttest(protocol_name, cond1, cond2,  analysis_type, abs_type, subjects_list)
%   analysis_type:   e.g. 'sloreta_fixed_surf'
%
function sFiles = brainstorm_group_stats_2cond_pairedttest(protocol_name, cond1, cond2,  analysis_type, abs_type, subjects_list)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    len_subj                = length(subjects_list);
    FileNamesA              = cell(1, len_subj);
    FileNamesB              = cell(1, len_subj);
    
    for nsubj=1:len_subj
        bst_path1    = fullfile(subjects_list{nsubj}, cond1, ['results_' cond1 '_' analysis_type '.mat']);
        full_path1   = file_fullpath(bst_path1);
        
        bst_path2    = fullfile(subjects_list{nsubj}, cond2, ['results_' cond2 '_' analysis_type '.mat']);
        full_path2   = file_fullpath(bst_path2);
        
        if exist(full_path1,'file')
            FileNamesA{nsubj} = bst_path1;
        else
            disp(['Error in brainstorm_group_stats_2cond_pairedttest: file ' ]);
            sFiles = [];
            return;            
        end
        
        if exist(full_path2,'file')
            FileNamesB{nsubj} = bst_path2;
        else
            disp(['Error in brainstorm_group_stats_2cond_pairedttest: file ' ]);
            sFiles = [];
            return;            
        end
    end
 
    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: paired t-test
    sFiles = bst_process(...
        'CallProcess', 'process_ttest_paired', ...
        FileNamesA, FileNamesB, ...
        'abs_type', abs_type);  % D = abs(A)-abs(B)   - Default

    % Save and display report
    ReportFile      = bst_report('Save', sFiles);
    ...bst_report('Open', ReportFile);
    
    if isempty(sFiles)
        rep = load(ReportFile);
        rep.Reports{3,4}
       keyboard 
    end
    
    ResultFile = sFiles(1).FileName;
    sFiles={ResultFile};    
    
    % remove 'results' string from analysis_type
    analysis_type   = strrep(analysis_type, 'results_', '');
    
    % APPLY TAG NAME 
    sFiles = bst_process(...
    'CallProcess', 'process_add_tag', ...
    sFiles, [], ...
    'tag', analysis_type, ...
    'output', 1);  % Add to comment    
    
    src_filename    = fullfile(brainstorm_data_path, sFiles(1).FileName);
    dest_filename   = fullfile(brainstorm_data_path, '@inter', ['presults_' cond1 '_' cond2 '_' analysis_type '.mat']);
    movefile(src_filename, dest_filename, 'f');
    
    db_reload_studies(sFiles(1).iStudy);
end
