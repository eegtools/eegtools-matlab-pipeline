function sFiles = brainstorm_subject_conditions_differences(db_name, subj_name, cond1, cond2)

    iProtocol               = brainstorm_protocol_open(db_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;

    % Input files
    FileNamesA = {fullfile(subj_name, cond1,  ['average_data_average_' cond1 '.mat'])};
    FileNamesB = {fullfile(subj_name, cond2,  ['average_data_average_' cond2 '.mat'])};

    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Difference: A-B
    sFiles = bst_process('CallProcess', 'process_diff_ab', FileNamesA, FileNamesB);

    brainstorm_utility_check_process_success(sFiles);   
    
    src_filename    = sFiles(1).FileName;
    dest_filename   = fullfile(subj_name,  new_condition_name, 'data_average.mat');
    
    srcfile         = fullfile(brainstorm_data_path, src_filename);
    destfile        = fullfile(brainstorm_data_path, dest_filename);
    
    movefile(srcfile, destfile);    
    
    
end