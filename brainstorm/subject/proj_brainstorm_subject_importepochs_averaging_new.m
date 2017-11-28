
function result = proj_brainstorm_subject_importepochs_averaging_new(project, varargin) ... settings_path, protocol_name, input_folder, subj_name, analysis_name, brainstorm_channels_file)
    
iProtocol                   = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                    = bst_get('ProtocolInfo');
brainstorm_data_path        = protocol.STUDIES;

list_select_subjects    = project.subjects.list;

for par=1:2:length(varargin)
    switch varargin{par}
        case { 'list_select_subjects', ...
                }
            
            if isempty(varargin{par+1})
                continue;
            else
                assign(varargin{par}, varargin{par+1});
            end
    end
end



if not(exist(project.brainstorm.channels_file_path, 'file'))
    disp('channels_file_type file is missing...exiting');
    result = 0;
    ...return;
end
... sample_lenght_in_seconds    = 1/project.eegdata.fs;   ... in seconds
    ... bs_bc_end = project.epoching.bc_end.s; ...- sample_lenght_in_seconds;
    ... bs_epoch_end = project.epoching.epo_end.s - sample_lenght_in_seconds;
    


for subj=1:length(list_select_subjects)
    
    subj_name = list_select_subjects{subj};
    
    if isempty(bst_get('Subject', subj_name))
        db_add_subject(subj_name, [], 1, 1);
    end
    
    for cond=1:project.epoching.numcond
        cond_name=project.epoching.condition_names{cond};
        
        input_file=fullfile(project.paths.output_epochs, [project.import.original_data_prefix subj_name project.import.original_data_suffix project.import.output_suffix project.epoching.input_suffix '_' cond_name '.set']);
        if not(exist(input_file, 'file'))
            disp('epoch file is missing...exiting');
            result = 0;
            return;
        end
        % Input files
        FileNamesA = [];
        
        % Start a new report
        bst_report('Start', FileNamesA);
        
        % Process: Import MEG/EEG: Time
        sFiles = bst_process(...
            'CallProcess', 'process_import_data_epoch', ...
            FileNamesA, [], ...
            'subjectname', subj_name, ...
            'condition', cond_name, ...
            'datafile', {{input_file}, 'EEG-EEGLAB'}, ...
            'iepochs', [], ...
            'channelalign', 1, ...
            'usectfcomp', 0, ...
            'usessp', 0, ...
            'freq', {project.eegdata.fs, 'Hz', 0}, ...
            'baseline', [project.epoching.bc_st.s, project.epoching.bc_end.s]);
        
        sEpochsFiles = sFiles;            % may be we want to delete imported epochs
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
        'channelfile', {project.brainstorm.channels_file_path, project.brainstorm.channels_file_type}, ...
        'usedefault', 0, ...
        'channelalign', 1);
    
    % Save and display report
    ReportFile = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);
    result = 1;
end

end