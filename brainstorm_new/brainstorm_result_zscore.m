
function brainstorm_result_zscore(protocol_name, result_file, baseline, varargin)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    source_abs              = 1;
    dynamic                 = 0;
    
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
            case 'source_abs'
                source_abs  = varargin{opt+1}; 
            case 'dynamic'
                dynamic     = varargin{opt+1};
        end
    end
    
    
    % define optional parameters, accepted varargin parameters are:
    % Input files
    FileNamesA = {result_file};

    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Z-score normalization: 
    sFiles = bst_process( ...
        'CallProcess', 'process_zscore_dynamic', ...
        FileNamesA, [], ...
        'baseline', baseline, ...
        'source_abs', source_abs, ...
        'dynamic', dynamic);

    % Check results
    if isempty(sFiles)
        ReportFile  = bst_report('Save', sFiles);
        bst_report('Open', ReportFile);        
        rep         = load(ReportFile);
        rep.Reports{3,4}
        keyboard 
    end     
    
%     output_file_name=sFiles(1).FileName;
%     
%     [idir,iname,iext]   = fileparts(result_file);
%     [odir,oname,oext]   = fileparts(output_file_name);
%     
%     iname               = strrep(iname, 'results_', '');
%     
%     src                 = fullfile(brainstorm_data_path, output_file_name);
%     dest                = fullfile(brainstorm_data_path, odir, ['matrix_' iname  oext]);
%     movefile(src,dest);
    
    db_reload_studies(sFiles(1).iStudy);
end