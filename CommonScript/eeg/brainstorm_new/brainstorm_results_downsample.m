... result file must be 'subj_name/cond_name/results_wmne.mat'

function ResultFile = brainstorm_results_downsample(protocol_name, result_file, atlas_name)  

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;

    % Input file
    FileNamesA = {result_file};

    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Downsample to atlas
    sFiles = bst_process(...
        'CallProcess', 'process_source_atlas', ...
        FileNamesA, [], ...
        'atlas', atlas_name, ...
        'isnorm', 0);
    
    output_file_name=sFiles(1).FileName;
    
    [idir,iname,iext]   = fileparts(result_file);
    [odir,oname,oext]   = fileparts(output_file_name);
    
    src                 = fullfile(brainstorm_data_path, output_file_name);
    dest                = fullfile(brainstorm_data_path, odir, [iname '_' atlas_name oext]);
    movefile(src,dest);
    
    ResultFile          = fullfile(odir, [oname '_' atlas_name oext]);    
    
    db_reload_studies(sFiles(1).iStudy);
    
    % Save and display report
    ReportFile          = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);
end

