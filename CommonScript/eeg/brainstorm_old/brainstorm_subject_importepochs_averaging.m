
function brainstorm_subject_importepochs_averaging(settings_path, protocol_name, input_folder, subj_name, analysis_name, brainstorm_channels_file)

    iProtocol = brainstorm_protocol_open(protocol_name);
    protocol = bst_get('ProtocolInfo');
    brainstorm_data_path = protocol.STUDIES;
    
    % load configuration file
    [path,name_noext,ext] = fileparts(settings_path);
    addpath(path);    eval(name_noext);

    sample_lenght_in_seconds=1/fs;   ... in seconds
    bs_bc_end = - sample_lenght_in_seconds;
    bs_epoch_end = epo_end - sample_lenght_in_seconds;
    
    if isempty(bst_get('Subject', subj_name))
        db_add_subject(subj_name, [], 1, 1);
    end
    
    for cond=1:length(name_cond) 
        
        input_dataset=fullfile(input_folder, [subj_name '_' analysis_name '_' name_cond{cond} '.set']);
        % Input files
        FileNamesA = [];

        % Start a new report
        bst_report('Start', FileNamesA);

        % Process: Import MEG/EEG: Time
        sFiles = bst_process(...
            'CallProcess', 'process_import_data_epoch', ...
            FileNamesA, [], ...
            'subjectname', subj_name, ...
            'condition', name_cond{cond}, ...
            'datafile', {{input_dataset}, 'EEG-EEGLAB'}, ...
            'iepochs', [], ...
            'channelalign', 1, ...
            'usectfcomp', 0, ...
            'usessp', 0, ...
            'freq', {fs, 'Hz', 0}, ...
            'baseline', [epo_st, bs_bc_end]);
        
        sEpochsFiles=sFiles;            % may be we want to delete imported epochs
        % Save and display report
        ReportFile = bst_report('Save', sFiles);
        bst_report('Open', ReportFile);        

        % Start a new report
        bst_report('Start', FileNamesA);      
        % Process: Average: By trial group (subject average)
        sFiles = bst_process(...
            'CallProcess', 'process_average', ...
            sFiles, [], ...
            'avgtype', 3, ...  % By condition (subject average)
            'keepevents', 0);
        
        % Save and display report
        ReportFile = bst_report('Save', sFiles);
        bst_report('Open', ReportFile);
        
        outputfile = sFiles(1).FileName;
        [dir,name,ext] = fileparts(outputfile);
        src=fullfile(brainstorm_data_path, dir, [name ext]);
        dest=fullfile(brainstorm_data_path, dir, ['data_average' ext]);
        movefile(src,dest);        
        
    end
    
    % Start a new report
    bst_report('Start', sFiles);
        
    % Process: Set channel file
    sFiles = bst_process(...
    'CallProcess', 'process_import_channel', ...
    sFiles, [], ...
    'channelfile', {brainstorm_channels_file, 'POLHEMUS'}, ...
    'usedefault', 0, ...
    'channelalign', 1);  

    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);

end

