
function proj_brainstorm_subject_tf_conditions(project, varargin) ... settings_path, protocol_name, subj_name, level_name,varargin)
    
iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

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



for subj=1:length(list_select_subjects)
    subj_name = list_select_subjects{subj};
    
    
    for f=1:length(project.study.factors)
        
        
        level_name =  project.study.factors(f).level;
        file_matches = project.study.factors(f).file_match;
        
        
        % contains condition names...
        lev_num             = length(file_matches);
        
        
%         iStudies                = db_add_condition(subj_name, level_name, 1);
        
        FileNamesA = {};
        num_epochs=0;
        
        for lev=1:lev_num
            
            lev_name   = file_matches{lev};
            studies     = bst_get('StudyWithCondition', [subj_name '/' lev_name ]);
            
            if not(isempty(studies))
                for nf=1:length(studies.Data)
                    file=studies.Data(nf);
                    
                    srcfilename        = fullfile(brainstorm_data_path,studies.Data(nf).FileName);
                    if exist(srcfilename)
                        
                        %                         [PATHSTR,NAME,EXT] = fileparts(srcfilename);
                        %                         name_dest = [NAME, EXT];
                        
                        %                         destfilename        = fullfile(brainstorm_data_path, subj_name, level_name,  name_dest);
                        
                        %                         copyfile(srcfilename,destfilename );
                        if (~isempty(strfind(file.Comment, lev_name)) && ~isempty(strfind(file.Comment, ' (#')))
                            num_epochs              = num_epochs+1;
                            FileNamesA{num_epochs}  = file.FileName;
                            
                        end
                        
                        
                    end
                end
                
                if length(FileNamesA)>2
                    
                    
                    % Start a new report
                    bst_report('Start', FileNamesA);
                    
                    % Process: Time-frequency (Morlet wavelets)
                    FileNamesA = bst_process('CallProcess', 'process_timefreq', FileNamesA, [], ...
                        'sensortypes', ' EEG', ...
                        'edit',        struct(...
                        'Comment',         [project.brainstorm.tf.measure, ',', project.brainstorm.tf.output], ...
                        'TimeBands',       [], ...
                        'Freqs',           project.brainstorm.tf.Freqs, ...
                        'MorletFc',        project.brainstorm.tf.MorletFc,...1, ...
                        'MorletFwhmTc',    project.brainstorm.tf.MorletFwhmTc,...3, ...
                        'ClusterFuncTime', 'none', ...
                        'Measure',         project.brainstorm.tf.measure,...'power', ...
                        'Output',          project.brainstorm.tf.output,...'average', ...
                        'RemoveEvoked',    project.brainstorm.tf.RemoveEvoked,...1, ...
                        'SaveKernel',      0), ...
                        'normalize',   project.brainstorm.tf.normalize...'multiply'...
                        );  % 1/f compensation: Multiply output values by frequency
                    
                    % Save and display report
                    ReportFile = bst_report('Save', FileNamesA);
                    bst_report('Open', ReportFile);
                    % bst_report('Export', ReportFile, ExportDir);
                    
                    src_filename    = FileNamesA(1).FileName;
                    dest_filename   = fullfile(subj_name, level_name, 'timefreq_morlet.mat');
                    
                    srcfile         = fullfile(brainstorm_data_path, src_filename);
                    destfile        = fullfile(brainstorm_data_path, dest_filename);
                    
                    movefile(srcfile, destfile);
                    
%                     iStudies = bst_get('StudyWithSubject', subj_name);
%                     db_reload_studies(iStudies);
%                     [FileNamesA, iStudies] = bst_get('StudyWithCondition', [subj_name '/@intra']);
%                     db_reload_studies(iStudies);
                end
            end
        end
    end
    db_reload_database(iProtocol);
end