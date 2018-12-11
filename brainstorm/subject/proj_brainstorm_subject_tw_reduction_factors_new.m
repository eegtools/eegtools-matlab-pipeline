% orient:       fixed, free, loose
% norm:         wmne, dspm, sloreta
% tag:          whichever string
% loose_value

function  proj_brainstorm_subject_tw_reduction_factors_new(project,  varargin)

iProtocol               = brainstorm_protocol_open(project.brainstorm.db_name);
protocol                = bst_get('ProtocolInfo');
brainstorm_data_path    = protocol.STUDIES;

time_reduction_tag_list  = project.brainstorm.postprocess.time_reduction_tag_list;

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



for nd  = 1:length(project.postprocess.erp.design)
    
    %     nd = 1;
    
    tws_d = project.postprocess.erp.design(nd).group_time_windows;
    
    %         ntwd = 1;
    for ntwd = 1:length(tws_d)
        
        tw_name{ntwd} = tws_d(ntwd).name;
        tw_lim_s{ntwd}  = [tws_d(ntwd).min tws_d(ntwd).max]/1000;
        
        
        
        
        
        for t=1:length(time_reduction_tag_list)
            
            tag         = time_reduction_tag_list{t};
            input_file  = [project.brainstorm.average_file_name '.mat'];   % e.g. 'data_average.mat'
            
            for cond  =1:length(project.study.factors)
                
                cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_select_subjects, project.study.factors(cond).level, input_file, tag);
                
                for s=1:length(cond_files)
                    
                    
                    result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files{s});
                    
                    brainstorm_subject_results_tw_reduction(result_file,  tw_lim_s(ntwd), 'average',      ['_', tw_name{ntwd}]);
                    
                    
                end
            end
        end
        
    end
end

%     for nd  = 1:length(project.postprocess.erp.design)
%
%         %     nd = 1;
%
%         tws_d = project.postprocess.erp.design(nd).group_time_windows;
%
%         %         ntwd = 1;
%         for ntwd = 1:length(tws_d)
%
%             tw_name{ntwd} = tws_d(ntwd).name;
%             tw_lim_s{ntwd}  = [tws_d(ntwd).min tws_d(ntwd).max]/1000;
%             for t=1:length(project.brainstorm.postprocess.tag_list)
%
%                 tag         = project.brainstorm.postprocess.tag_list{t};
%
%                 tag2 = [tag, ' | tw_average_',tw_name{ntwd}];
%
%
%                 input_file  = [project.brainstorm.average_file_name '.mat'];   % e.g. 'data_average.mat'
%
%                 for cond  =1 :length(project.study.factors)
%
%                     cond_files = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, project.study.factors(cond).level, input_file, tag);
%                     cond_files2 = brainstorm_results_get_from_subjectslist_by_tag(list_subjects, project.study.factors(cond).level, input_file, tag2);
%
%
%                     for s=1:length(cond_files)
%
%
%                         %                 result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files2{s});
%
%                         %                 brainstorm_subject_results_tw_reduction(result_file, tw_lim_s, 'average',      ['_', tw_name{ntwd}]);
%
%                         result_file = fullfile(project.paths.project, project.brainstorm.db_name, 'data', cond_files2{s});
%                         brainstorm_result_uncontrained2flat(project.brainstorm.db_name, result_file, source_flatting_method);
%
%
%                     end
%                 end
%             end
%
%         end
%     end
%
%
%
%
%
end


