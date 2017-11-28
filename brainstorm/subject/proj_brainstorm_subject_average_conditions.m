
function proj_brainstorm_subject_average_conditions(project, subj_name, new_condition_name, varargin) ... settings_path, protocol_name, subj_name, new_condition_name,varargin)

    iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
    protocol                = bst_get('ProtocolInfo');
    brainstorm_data_path    = protocol.STUDIES;
    
    % varargin management: contains condition names...
    options_num             = size(varargin,2);
    
    iStudies                = db_add_condition(subj_name, new_condition_name, 1);
    
    FileNamesA = {};
    num_epochs=0;    
    for cond=1:options_num
        cond_name   = varargin{cond};
        studies     = bst_get('StudyWithCondition', [subj_name '/' cond_name ]);

        for nf=1:length(studies.Data);
            file=studies.Data(nf);
            if (~isempty(strfind(file.Comment, cond_name)) && ~isempty(strfind(file.Comment, ' (#')))
                num_epochs              = num_epochs+1;
                FileNamesA{num_epochs}  = file.FileName;
            end
        end
    end
    
    % Start a new report
    bst_report('Start', FileNamesA);

    % Process: Average: By trial group (subject average)
    sFiles = bst_process(...
        'CallProcess', 'process_average', ...
        FileNamesA, [], ...
        'avgtype', 2, ...  % By subject
        'keepevents', 0);


    % Save and display report
    ReportFile      = bst_report('Save', sFiles);
    bst_report('Open', ReportFile);  
    
    src_filename    = sFiles(1).FileName;
    dest_filename   = fullfile(subj_name, new_condition_name, 'data_average.mat');
    
    srcfile         = fullfile(brainstorm_data_path, src_filename);
    destfile        = fullfile(brainstorm_data_path, dest_filename);
    
    movefile(srcfile, destfile);
    
    %iStudies = bst_get('StudyWithSubject', subj_name);
    db_reload_studies(iStudies);   
    [sStudies, iStudies] = bst_get('StudyWithCondition', [subj_name '/@intra']);
    db_reload_studies(iStudies);   
        
end

