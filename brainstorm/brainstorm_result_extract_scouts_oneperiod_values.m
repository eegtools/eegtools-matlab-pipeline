% time_limits in seconds
function brainstorm_result_extract_scouts_oneperiod_values(protocol_name, result_file, scouts_name, time_limits, time_label, varargin)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    scouts_label            = '';
    for x=1:length(scouts_name)
        scouts_label = [scouts_label '_' scouts_name{x}];
    end
        
    isnorm                  = 1;
    scoutfunc               = 1;
    doavgtime               = 1;
    
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
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
            case 'doavgtime'
                doavgtime = varargin{opt+1};                
        end
    end
    
    
    % define optional parameters, accepted varargin parameters are:
    % Input files
    FileNamesA = {result_file};

    % Start a new report
    bst_report('Start', FileNamesA);

    
    sFiles = bst_process('CallProcess', 'process_extract_values', FileNamesA, [], ...
        'timewindow', time_limits, ...
        'scouts', {'User scouts', scouts_name}, ...
        'scoutfunc', scoutfunc, ...  % Mean, Max, PCA, Std, All
        'isnorm',     isnorm, ...
        'avgtime',    doavgtime, ...
        'dim',        2, ...  % Concatenate time (dimension 2)
        'Comment',    '');    
    
    % Save report
    ReportFile      = bst_report('Save', sFiles);
    if isempty(sFiles)
        bst_report('Open', ReportFile);        
        rep = load(ReportFile);
        rep.Reports{3,4}
       keyboard 
    end     
    
    output_file_name=sFiles(1).FileName;
    
    [idir,iname,iext]   = fileparts(result_file);
    [odir,oname,oext]   = fileparts(output_file_name);
    
    iname               = strrep(iname, 'results_', '');
    
    src                 = fullfile(brainstorm_data_path, output_file_name);
    dest                = fullfile(brainstorm_data_path, odir, ['matrix_' iname '_scouts' scouts_label '_' time_label oext]);
    movefile(src,dest);
    
    db_reload_studies(sFiles(1).iStudy);
end