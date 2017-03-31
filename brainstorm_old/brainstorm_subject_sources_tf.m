function ResultFile = brainstorm_subject_sources_tf(protocol_name, result_file, time_struct, band_struct)

    iProtocol = brainstorm_protocol_open(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;

    band_name = band_struct{1};
        
    % Input file
    FileNamesA = {result_file};
    
    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Time-frequency (Morlet wavelets)
    sFiles = bst_process(...
        'CallProcess', 'process_timefreq', ...
        FileNamesA, [], ...
        'clusters', [], ...
        'edit', struct(...
             'Comment', ['Power,' band_name], ...
             'TimeBands', time_struct, ...
             'Freqs', band_struct, ...
             'MorletFc', 2, ...
             'MorletFwhmTc', 3, ...
             'ClusterFuncTime', 'none', ...
             'Measure', 'power', ...
             'Output', 'all', ...
             'SaveKernel', 0));
         
    output_file_name=sFiles(1).FileName;
    
    [idir,iname,iext] = fileparts(result_file);
    [odir,oname,oext] = fileparts(output_file_name);
    
    iname = strrep(iname, 'results_', '');
    
    src=fullfile(brainstorm_data_path, output_file_name);
    dest=fullfile(brainstorm_data_path, odir, ['timefreq_morlet_' iname '_' band_name oext]);
    movefile(src,dest);
    ResultFile=fullfile(odir, ['timefreq_morlet_' iname '_' band_name oext]);    
    
    db_reload_studies(sFiles(1).iStudy);         

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

end