
function ResultsFile = brainstorm_extract_scouts_timeseries(protocol_name, subj_name, norm_str, settings_path, varargin)

    iProtocol = brainstorm_open_protocol(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;
    
    %read the configuration file
    fid=fopen(settings_path, 'r'); %~ischar(fgetl(fid))
    while 1   
        tline = fgetl(fid);
        if ~ischar(tline), break, end
        eval(tline);
    end
    fclose(fid);
    
    
    
    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Extract scouts time series: 1
    sFiles = bst_process(...
        'CallProcess', 'process_extract_cluster', ...
        FileNamesA, [], ...
    'clusters', [...
         struct(...
            'Vertices', [7958, 8050, 8064, 8066, 8077, 8124, 8420, 8442, 8452, 8459, 8473, 8510, 8545, 8547, 8587, 8629, 8632, 8638, 8681, 8713, 8783, 8818, 8837, 8886, 8937, 8952, 8975, 9047, 9056], ...
            'Seed', 8547, ...
            'Color', [0.0431372549, 0.5176470588, 0.7803921569], ...
            'Label', 'rEBA', ...
            'Function', 'Mean', ...
            'Region', 'UU', ...
            'Handles', repmat(struct('hFig', [], 'hScout', [], 'hLabel', [], 'hVertices', [], 'hPatch', [], 'hContour', []), 0)), ...
         struct(...
            'Vertices', [8285, 8360, 8395, 8399, 8420, 8424, 8429, 8442, 8444, 8450, 8452, 8459, 8466, 8473, 8497, 8501, 8506, 8510, 8532, 8545, 8547, 8572, 8587, 8594, 8599, 8615, 8623, 8629, 8632, 8635, 8638, 8640, 8670, 8675, 8681, 8683, 8713, 8724, 8732, 8763, 8768, 8802, 8845, 8915, 8974, 8975, 8978, 9079, 9141, 9179, 9221, 9252], ...
            'Seed', 8681, ...
            'Color', [0, 0.8, 0], ...
            'Label', '1', ...
            'Function', 'Mean', ...
            'Region', 'UU', ...
            'Handles', repmat(struct('hFig', [], 'hScout', [], 'hLabel', [], 'hVertices', [], 'hPatch', [], 'hContour', []), 0))], ...
    'isnorm', 0, ...
    'concatenate', 0, ...
    'save', 1);

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

    % rename output files in order to: remove date/time and standardize names
    % format name as: results_[wmne/dspm/sloreta]_loose if applicable
    dest_name=['results_' norm_str];
    if (strcmp(source_orient, 'loose'))
        dest_name=[dest_name '_loose'];
    end

    for nf=1:length(ResultsFile)
        [dir,name,ext] = fileparts(ResultsFile{nf});
        src=fullfile(brainstorm_data_path, dir, [name ext]);
        dest=fullfile(brainstorm_data_path, dir, [dest_name ext]);
        movefile(src,dest);
        ResultsFile{nf}=fullfile(dir, [dest_name ext]);
    end
    
%     [sSubject, iSubject] = bst_get('Subject', subj_name);
%     db_reload_subjects(iSubject);

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

end

