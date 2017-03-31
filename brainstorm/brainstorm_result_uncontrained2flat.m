%% function brainstorm_result_uncontrained2flat(protocol_name, result_file, varargin)
% convert an uncontranstrained 3 dimensional vector in a single scalar
% method - 1: Norm = sqrt(x^2+y^2+z^2)
%        - 2: PCA 
function brainstorm_result_uncontrained2flat(protocol_name, result_file, varargin)

    iProtocol               = brainstorm_protocol_open(protocol_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    method                  = 1;
    
    options_num=size(varargin,2);
    for opt=1:2:options_num
        switch varargin{opt}
            case 'method'
                method  = varargin{opt+1}; 
        end
    end
    
    
    % define optional parameters, accepted varargin parameters are:
    % Input files
    FileNamesA = {result_file};

    % Start a new report
    bst_report('Start', FileNamesA);


    % Process: Unconstrained to flat map
    sFiles = bst_process( ...
            'CallProcess', 'process_source_flat', ...
             FileNamesA, [], ...
            'method', method); 

    brainstorm_utility_check_process_success(sFiles);    
    
    output_file_name    = sFiles(1).FileName;    
    [odir,oname, oext]  = fileparts(output_file_name);
    [idir,iname, iext]  = fileparts(result_file);
    
    src                 = fullfile(brainstorm_data_path, output_file_name);
    dest                = fullfile(brainstorm_data_path, odir, [iname '_norm' iext]);
    movefile(src,dest);
    
    db_reload_studies(sFiles(1).iStudy);
end