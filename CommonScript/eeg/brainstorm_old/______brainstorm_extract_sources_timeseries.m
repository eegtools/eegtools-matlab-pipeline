
function ResultsFile = brainstorm_extract_sources_timeseries(protocol_name, subj_name, norm_str, settings_path, varargin)

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
    
    % define optional parameters
    % accepted varargin parameters are: 
    % 'nodepth' ...currently disabled
    % 'loose', val    
    depth_value=1;
    source_orient='fixed';
    loose_value=std_loose_value;

    switch norm_str
        case 'wmne'
            norm_value=1;
        case 'dspm'
            norm_value=2;
        case 'sloreta'
            norm_value=3;
            depth_value=0;
    end    
    
    options_num=size(varargin,2);
    for opt=1:options_num
        switch varargin{opt}
            %case 'nodepth'
            %    depth_value=0;
            case 'loose'
                source_orient='loose';
                opt=opt+1;
                loose_value=varargin{opt};
        end
    end
    
    % define conditions inputs
    FileNamesA=cell(1,length(name_cond));
    for cond=1:length(name_cond)
        FileNamesA{cond}=fullfile(subj_name, name_cond{cond}, 'data_average.mat'); % 'alessandra_finisguerra/cscrambled/data_average.mat', ...
    end 
    
    
    
    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Extract scouts time series: 1
    sFiles = bst_process(...
        'CallProcess', 'process_extract_cluster', ...
        FileNamesA, [], ...
        'clusters', struct(...
        'Vertices', [8285, 8360, 8395, 8399, 8420, 8424, 8429, 8442, 8444, 8450, 8452, 8459, 8466, 8473, 8497, 8501, 8506, 8510, 8532, 8545, 8547, 8572, 8587, 8594, 8599, 8615, 8623, 8629, 8632, 8635, 8638, 8640, 8670, 8675, 8681, 8683, 8713, 8724, 8732, 8763, 8768, 8802, 8845, 8915, 8974, 8975, 8978, 9079, 9141, 9179, 9221, 9252], ...
        'Seed', 8681, ...
        'Color', [0, 0.8, 0], ...
        'Label', '1', ...
        'Function', 'Mean', ...
        'Region', 'UU', ...
        'Handles', repmat(struct('hFig', [], 'hScout', [], 'hLabel', [], 'hVertices', [], 'hPatch', [], 'hContour', []), 0)), ...
        'isnorm', 0, ...
        'concatenate', 0, ...
        'save', 1);

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

    
    
    
    
    
    
    % Start a new report
    bst_report('Start', FileNamesA);    

   
    % do source analysis over all the conditions
    sFiles = bst_process(...
        'CallProcess', 'process_inverse', ...
        sFiles, [], ...
        'method', norm_value, ...  % 
        'wmne', struct(...
             'NoiseCov', [], ...
             'InverseMethod', norm_str, ...
             'SNR', 3, ...
             'diagnoise', 0, ...
             'SourceOrient', {{source_orient}}, ...
             'loose', loose_value, ...
             'depth', depth_value, ...
             'weightexp', 0.5, ...
             'weightlimit', 10, ...
             'regnoise', 1, ...
             'magreg', 0.1, ...
             'gradreg', 0.1, ...
             'eegreg', 0.1, ...
             'ecogreg', 0.1, ...
             'seegreg', 0.1, ...
             'fMRI', [], ...
             'fMRIthresh', [], ...
             'fMRIoff', 0.1, ...
             'pca', 1), ...
        'sensortypes', 'EEG', ...
        'output', 3);  % Full results: one per file
    
    ResultsFile = {sFiles.FileName};
    
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

