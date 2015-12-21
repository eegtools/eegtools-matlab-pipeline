
function brainstorm_subject_sources_extract_scouts(protocol_name, time_limits, scouts_name, varargin)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    
    isflip                  = 1;
    isnorm                  = 1;
    scoutfunc               = 1;
    
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
            case 'isflip'
                isflip = varargin{opt+1}; 
            case 'isnorm'
                isnorm = varargin{opt+1};
            case 'scoutfunc'
                scoutfunc_str = varargin{opt+1};                
                switch scoutfunc_str
                    case 'mean'
                        scoutfunc = 1;
                    case 'max'
                        scoutfunc = 2;
                    case 'pca'
                        scoutfunc = 3;
                    case 'std'
                        scoutfunc = 4;
                    case 'all'
                        scoutfunc = 5;
                end 
        end
    end
    
    
    % define optional parameters, accepted varargin parameters are:
    % Input files
    FileNamesA = {result_file};

    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Scouts time series: leg_SM1 rightIF
    sFiles = bst_process('CallProcess', 'process_extract_scout', FileNamesA, [], ...
        'timewindow', time_limits, ...
        'scouts', {'User scouts', scouts_name}, ...
        'scoutfunc', scoutfunc, ...  % Mean, Max, PCA, Std, All
        'isflip', isflip, ...
        'isnorm', isnorm, ...
        'concatenate', 1, ...
        'save', 1, ...
        'addrowcomment', 1, ...
        'addfilecomment', 1);

    
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