% function sFiles = brainstorm_conditions_differences_new(db_name, subj_name, cond1, cond2)
function sFiles = proj_brainstorm_conditions_differences_new(project, varargin)


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
    
    
    for pwc=1:length(project.brainstorm.sensors.pairwise_comparisons)
        
        cond1 = project.brainstorm.sensors.pairwise_comparisons{pwc}{1}; 
        cond2 = project.brainstorm.sensors.pairwise_comparisons{pwc}{2};
        
        sFiles = brainstorm_subject_conditions_differences(project.brainstorm.db_name, subj_name, cond1, cond2);
        
%         % Input files
%         FileNamesA = {fullfile(brainstorm_data_path,subj_name, cond1,  ['data_average.mat'])};
%         FileNamesB = {fullfile(brainstorm_data_path,subj_name, cond2,  ['data_average.mat'])};
%         
%         if exist(FileNamesA{:}) &&  exist(FileNamesB{:})
%             
%             % Start a new report
%             bst_report('Start', FileNamesA);
%             
%             % Process: Difference: A-B
%             sFiles = bst_process('CallProcess', 'process_diff_ab', FileNamesA, FileNamesB);
%             if not(isempty(sFiles))
%                 
%                 brainstorm_utility_check_process_success(sFiles);
%                 
%                 new_condition_name = [cond1,'-',cond2];
%                 
%                 src_filename    = sFiles(1).FileName;
%                 dest_filename   = fullfile(subj_name,  new_condition_name, 'data_average.mat');
%                 
%                 srcfile         = fullfile(brainstorm_data_path, src_filename);
%                 destfile        = fullfile(brainstorm_data_path, dest_filename);
%                 
%                 movefile(srcfile, destfile);
%             end
%         end
    end
end
end