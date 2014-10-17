... model_type 1: surface, 2: vol
function brainstorm_subject_bem(settings_path, protocol_name, subj_name, varargin)

    iProtocol = brainstorm_protocol_open(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;
    
    % load configuration file
    [path,name_noext,ext] = fileparts(settings_path);
    addpath(path);    eval(name_noext);

    model_type=1;
    
    options_num=size(varargin,2);
    for opt=1:options_num
        switch varargin{opt}
            case 'model_type'
                opt=opt+1;
                model_type=varargin{opt};
        end
    end    
    
    
    FileNamesA=cell(1,1);
    FileNamesA{1}=fullfile(subj_name, name_cond{1}, 'data_average.mat'); % 'alessandra_finisguerra/cscrambled/data_average.mat', ...
 
    % Start a new report involving just the first file and performing BEM modeling and noise estimation
    bst_report('Start', FileNamesA);

    % Process: Compute head model
    sFiles = bst_process(...
        'CallProcess', 'process_headmodel', ...
        FileNamesA, [], ...
        'sourcespace', model_type, ...
        'meg', 3, ...  % Overlapping spheres
        'eeg', 3, ...  % OpenMEEG BEM
        'ecog', 2, ...  % OpenMEEG BEM
        'seeg', 2, ...
        'openmeeg', struct(...
             'BemSelect', [1, 1, 1], ...
             'BemCond', [1, 0.0125, 1], ...
             'BemNames', {{'Scalp', 'Skull', 'Brain'}}, ...
             'BemFiles', {{}}, ...
             'isAdjoint', 0, ...
             'isAdaptative', 1, ...
             'isSplit', 0, ...
             'SplitLength', 4000));
    
    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);
    
end

