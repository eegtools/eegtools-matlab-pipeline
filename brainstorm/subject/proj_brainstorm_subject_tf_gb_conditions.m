function proj_brainstorm_subject_tf_gb_conditions(project, varargin) ... settings_path, protocol_name, subj_name, level_name,varargin)
    

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

if not(isfield(project.brainstorm,'condition_names'))
    project.brainstorm.condition_names = project.epoching.condition_names;
    project.brainstorm.numcond         = project.epoching.numcond;
end

% perform sources processing over subject/condition/data_average.mat
sources_results = cell(length(list_select_subjects), project.brainstorm.sensors.tot_num_contrasts);

for subj=1:length(list_select_subjects)
    
    subj_name = list_select_subjects{subj};
    
    for cond=1: project.brainstorm.numcond
        cond_name                       = project.brainstorm.condition_names{cond};
        
        
        
        input_file =  ['timefreq_morlet_',project.brainstorm.tf.bc.method, '.mat'];
        
        % define conditions inputs
        FileNamesA={};
        FileNamesA{1}=fullfile(subj_name, cond_name, input_file); % 'alessandra_finisguerra/cscrambled/data_average.mat', ...
        
        % Start a new report
        bst_report('Start', FileNamesA);
        
        FileNamesA = bst_process('CallProcess', 'process_tf_bands', FileNamesA, [], ...
            'isfreqbands', project.brainstorm.tf.gb.isfreqbands, ...
            'freqbands',   project.brainstorm.tf.gb.isfreqbands, ...
            'istimebands', project.brainstorm.tf.gb.istimebands, ...
            'timebands',   project.brainstorm.tf.gb.timebands, ...
            'overwrite',   0);
        
        %         brainstorm_utility_check_process_success(sFiles);
        %
        %
        %         ResultFile = sFiles(1).FileName;
        %         sFiles={ResultFile};
        %
        
        
        
        
        
%        db_reload_studies(iStudies); 
        
        
        
        
    end
end
db_reload_database(iProtocol);
end












% function proj_brainstorm_subject_tf_group_bands_conditions(project, varargin) ... settings_path, protocol_name, subj_name, level_name,varargin)
%
% iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
% protocol                = bst_get('ProtocolInfo');
% brainstorm_data_path    = protocol.STUDIES;
%
% list_select_subjects    = project.subjects.list;
%
% for par=1:2:length(varargin)
%     switch varargin{par}
%         case { 'list_select_subjects', ...
%                 }
%
%             if isempty(varargin{par+1})
%                 continue;
%             else
%                 assign(varargin{par}, varargin{par+1});
%             end
%     end
% end
%
%
%
% for subj=1:length(list_select_subjects)
%     subj_name = list_select_subjects{subj};
%
%
%     for f=1:length(project.study.factors)
%
%
%         level_name =  project.study.factors(f).level;
%         file_matches = project.study.factors(f).file_match;
%
%
%         % contains condition names...
%         lev_num             = length(file_matches);
%
%
%         iStudies                = db_add_condition(subj_name, level_name, 1);
%
%         FileNamesA = {};
%         num_epochs=0;
%
%         for lev=1:lev_num
%
%             lev_name   = file_matches{lev};
%             studies     = bst_get('StudyWithCondition', [subj_name '/' lev_name ]);
%
%             if not(isempty(studies))
%                 for nf=1:length(studies.Data)
%                     file=studies.Data(nf);
%
%                     srcfilename        = fullfile(brainstorm_data_path,studies.Data(nf).FileName);
%                     if exist(srcfilename)
%
%                         %                         [PATHSTR,NAME,EXT] = fileparts(srcfilename);
%                         %                         name_dest = [NAME, EXT];
%
%                         %                         destfilename        = fullfile(brainstorm_data_path, subj_name, level_name,  name_dest);
%
%                         %                         copyfile(srcfilename,destfilename );
%                         if (~isempty(strfind(file.Comment, lev_name)) && ~isempty(strfind(file.Comment, ' (#')))
%                             num_epochs              = num_epochs+1;
%                             FileNamesA{num_epochs}  = file.FileName;
%
%                         end
%
%
%                     end
%                 end
%
%                 if length(FileNamesA)>2
%
%
%                     % Start a new report
%                     bst_report('Start', FileNamesA);
%
%                     % Process: Time-frequency (Morlet wavelets)
%                     FileNamesA = bst_process('CallProcess', 'process_timefreq', FileNamesA, [], ...
%                         'sensortypes', ' EEG', ...
%                         'edit',        struct(...
%                         'Comment',         'Avg,Power', ...
%                         'TimeBands',       [], ...
%                         'Freqs',           project.brainstorm.sensors.tf.Freqs, ...
%                         'MorletFc',        project.brainstorm.sensors.tf.MorletFc,...1, ...
%                         'MorletFwhmTc',    project.brainstorm.sensors.tf.MorletFwhmTc,...3, ...
%                         'ClusterFuncTime', 'none', ...
%                         'Measure',         'power', ...
%                         'Output',          'average', ...
%                         'RemoveEvoked',    project.brainstorm.sensors.tf.RemoveEvoked,...1, ...
%                         'SaveKernel',      0), ...
%                         'normalize',   project.brainstorm.sensors.tf.normalize...'multiply'...
%                         );  % 1/f compensation: Multiply output values by frequency
%
%                     % Save and display report
%                     ReportFile = bst_report('Save', FileNamesA);
%                     bst_report('Open', ReportFile);
%                     % bst_report('Export', ReportFile, ExportDir);
%
%                     src_filename    = FileNamesA(1).FileName;
%                     dest_filename   = fullfile(subj_name, level_name, 'timefreq_morlet.mat');
%
%                     srcfile         = fullfile(brainstorm_data_path, src_filename);
%                     destfile        = fullfile(brainstorm_data_path, dest_filename);
%
%                     movefile(srcfile, destfile);
%
%                     %iStudies = bst_get('StudyWithSubject', subj_name);
%                     db_reload_studies(iStudies);
%                     [FileNamesA, iStudies] = bst_get('StudyWithCondition', [subj_name '/@intra']);
%                     db_reload_studies(iStudies);
%                 end
%             end
%         end
%     end
% end