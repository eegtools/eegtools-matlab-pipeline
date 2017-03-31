function ResultFile = brainstorm_subject_sources_tf_timewnd_freqbands(protocol_name, result_file, time_struct, band_struct, do_zscore_overwrite, settings_path)

    % do_zscore_overwrite options:
    %  1: calculate zscore and overwrite tf result file
    %  0: calculate zscore and create new tf result zscore file
    % -1: do not calculate zscore
    
    iProtocol = brainstorm_protocol_open(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;

    %read the configuration file
    fid=fopen(settings_path, 'r');
    while 1   
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        eval(tline);
    end
    fclose(fid);    

    if ~isempty(time_struct)
        if iscell(time_struct{1})
            num_times=size(time_struct{1},1);
            arr = regexp (time_struct{1}{1,2}, ',', 'split');  ... split string by ','
            time_name=arr{1};
            for b=2:num_times
                times_str=time_struct{1}{b,2};
                arr = regexp (times_str, ',', 'split');
                time_name = [time_name ',' arr{1}];
            end
        end 
    end
    
    band_name='all bands';
    if iscell(band_struct{1})
        num_bands=size(band_struct{1},1);
        band_name=[band_struct{1}{1,1}];
        for b=2:num_bands
            band_name = [band_name '_' band_struct{1}{b,1}];
        end
    end
    
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
             'Comment', ['Power,' 'Bands: ' band_name], ...
             'TimeBands', time_struct, ...
             'Freqs', band_struct, ...
             'MorletFc', 2, ...
             'MorletFwhmTc', 3, ...
             'ClusterFuncTime', 'none', ...
             'Measure', 'power', ...
             'Output', 'all', ...
             'SaveKernel', 0));
      
    output_file_name=sFiles(1).FileName;
    iStudy=sFiles(1).iStudy;
    
    [idir,iname,iext] = fileparts(result_file);
    [odir,oname,oext] = fileparts(output_file_name);
    
    iname = strrep(iname, 'results_', '');
    
    src=fullfile(brainstorm_data_path, output_file_name);
    dest=fullfile(brainstorm_data_path, odir, ['timefreq_morlet_' iname '_' band_name oext]);
    movefile(src,dest);
    
    sFiles(1).FileName=fullfile(odir, ['timefreq_morlet_' iname '_' band_name oext]);
    
    if ne(do_zscore_overwrite, -1)
        % Process: Z-score normalization: []
        sFiles = bst_process(...
            'CallProcess', 'process_zscore', ...
            sFiles, [], ...
            'baseline', [epo_st, -0.004], ...
            'overwrite', do_zscore_overwrite);  
        
%         output_file_name=sFiles(1).FileName;

%         [idir,iname,iext] = fileparts(result_file);
%         [odir,oname,oext] = fileparts(output_file_name);
%         iname = strrep(iname, 'results_', '');

%         src=fullfile(brainstorm_data_path, output_file_name);
%         dest=fullfile(brainstorm_data_path, odir, ['timefreq_morlet_' iname '_' band_name '_zscore' oext]);
%         movefile(src,dest);
    end
         
    db_reload_studies(iStudy);         

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);
    
    ResultFile=fullfile(odir, ['timefreq_morlet_' iname '_' band_name '_zscore' oext]); 
end