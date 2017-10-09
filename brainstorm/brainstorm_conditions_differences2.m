function sFiles = brainstorm_conditions_differences2(db_name, subj_name, cond1, cond2)

iProtocol               = brainstorm_protocol_open(db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

% Input files
FileNamesA = {fullfile(brainstorm_data_path,subj_name, cond1,  ['data_average.mat'])};
FileNamesB = {fullfile(brainstorm_data_path,subj_name, cond2,  ['data_average.mat'])};
if exist(FileNamesA{:}) &&  exist(FileNamesB{:})
    
    % Start a new report
    bst_report('Start', FileNamesA);
    
    % Process: Difference: A-B
    sFiles = bst_process('CallProcess', 'process_diff_ab', FileNamesA, FileNamesB);
    if not(isempty(sFiles))
        
        brainstorm_utility_check_process_success(sFiles);
        
        new_condition_name = [cond1,'-',cond2];
        
        src_filename    = sFiles(1).FileName;
        dest_filename   = fullfile(subj_name,  new_condition_name, 'data_average.mat');
        
        srcfile         = fullfile(brainstorm_data_path, src_filename);
        destfile        = fullfile(brainstorm_data_path, dest_filename);
        
        movefile(srcfile, destfile);
    end
end

end