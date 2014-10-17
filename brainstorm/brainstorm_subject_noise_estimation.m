
function brainstorm_subject_noise_estimation(settings_path, protocol_name, subj_name)

    iProtocol = brainstorm_protocol_open(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;
    
    % load configuration file
    [path,name_noext,ext] = fileparts(settings_path);
    addpath(path);    eval(name_noext);
    
    % define conditions inputs
    FileNamesA=cell(1,length(name_cond));
    for cond=1:length(name_cond)
        FileNamesA{cond}=fullfile(subj_name, name_cond{cond}, 'data_average.mat');
    end
    
    % Start a new report
    bst_report('Start', FileNamesA);    
   
    % Compute noise covariance
    sFiles = bst_process(...
        'CallProcess', 'process_noisecov', ...
        FileNamesA, [], ...
        'baseline', [-0.4, -0.004], ...
        'dcoffset', 1, ...
        'method', 2, ...  % Diagonal matrix (better if: nTime < nChannel*(nChannel+1)/2)
        'copycond', 1, ...
        'copysubj', 0);
    
 
    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

end

